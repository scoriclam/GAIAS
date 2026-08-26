import fs from "fs";
import path from "path";

import {
    exchangeNpssoForAccessCode,
    exchangeAccessCodeForAuthTokens,
    getPurchasedGames,
} from "psn-api";


const PAGE_SIZE = 50;
const MAX_PAGES = 200;


function loadEnvFile(filePath) {
    const text = fs.readFileSync(
        filePath,
        "utf8",
    );

    const values = {};

    for (const line of text.split(/\r?\n/)) {
        const trimmed = line.trim();

        if (
            !trimmed
            || trimmed.startsWith("#")
            || !trimmed.includes("=")
        ) {
            continue;
        }

        const separator = trimmed.indexOf("=");

        const key = trimmed
            .slice(0, separator)
            .trim();

        const value = trimmed
            .slice(separator + 1)
            .trim();

        values[key] = value;
    }

    return values;
}


async function getAuthorization() {
    const envPath = path.resolve(".env");
    const env = loadEnvFile(envPath);

    const npsso = env.PSN_NPSSO;

    if (!npsso) {
        throw new Error(
            "PSN_NPSSO is missing from the root .env file.",
        );
    }

    const accessCode =
        await exchangeNpssoForAccessCode(
            npsso,
        );

    return exchangeAccessCodeForAuthTokens(
        accessCode,
    );
}


async function fetchFullLibrary(
    authorization,
) {
    const games = [];

    let start = 0;
    let pageNumber = 1;

    while (pageNumber <= MAX_PAGES) {
        const response = await getPurchasedGames(
            authorization,
            {
                size: PAGE_SIZE,
                start,
            },
        );

        const pageGames =
            response.data
                ?.purchasedTitlesRetrieve
                ?.games
            ?? [];

        games.push(...pageGames);

        if (pageGames.length < PAGE_SIZE) {
            return games;
        }

        start += pageGames.length;
        pageNumber += 1;
    }

    throw new Error(
        `Pagination exceeded ${MAX_PAGES} pages.`,
    );
}


async function main() {
    const authorization =
        await getAuthorization();

    const games =
        await fetchFullLibrary(
            authorization,
        );

    /*
     * stdout contains JSON only so Python can
     * consume this script programmatically.
     */
    process.stdout.write(
        JSON.stringify(games),
    );
}


main().catch((error) => {
    console.error(
        "PSN library fetch failed:",
        error.message,
    );

    process.exit(1);
});
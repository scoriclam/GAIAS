import fs from "fs";
import path from "path";

import {
    exchangeNpssoForAccessCode,
    exchangeAccessCodeForAuthTokens,
    getPurchasedGames,
} from "psn-api";


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

    const accessCode = await exchangeNpssoForAccessCode(
        npsso,
    );

    return exchangeAccessCodeForAuthTokens(
        accessCode,
    );
}


async function main() {
    const authorization = await getAuthorization();

    const response = await getPurchasedGames(
        authorization,
        {
            size: 50,
            start: 0,
        },
    );

    const games =
        response.data
            ?.purchasedTitlesRetrieve
            ?.games
        ?? [];

    console.log(
        "Purchased-games request succeeded.",
    );

    console.log(
        `Returned rows: ${games.length}`,
    );

    console.log();
    console.log(
        JSON.stringify(
            games.slice(0, 5),
            null,
            2,
        ),
    );
}


main().catch((error) => {
    console.error(
        "Purchased-games request failed:",
        error.message,
    );

    process.exit(1);
});
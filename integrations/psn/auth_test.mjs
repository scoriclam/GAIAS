import fs from "fs";
import path from "path";

import {
    exchangeNpssoForAccessCode,
    exchangeAccessCodeForAuthTokens,
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


async function main() {
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

    const authorization = await exchangeAccessCodeForAuthTokens(
        accessCode,
    );

    console.log("PSN authentication succeeded.");
    console.log(
        `Access token received: ${
            Boolean(authorization.accessToken)
        }`,
    );
    console.log(
        `Refresh token received: ${
            Boolean(authorization.refreshToken)
        }`,
    );
    console.log(
        `Expires in seconds: ${
            authorization.expiresIn
        }`,
    );
}


main().catch((error) => {
    console.error(
        "PSN authentication failed:",
        error.message,
    );

    process.exit(1);
});
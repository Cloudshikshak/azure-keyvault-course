const { DefaultAzureCredential } = require("@azure/identity");
const { SecretClient } = require("@azure/keyvault-secrets");

module.exports = async function (context, req) {
    context.log('JavaScript HTTP trigger function processed a request.');

    const keyVaultName = "<KEYVAULT_NAME>";
    const keyVaultURI = "https://" + keyVaultName + ".vault.azure.net";

    const credential = new DefaultAzureCredential();
    // Install 'keytar' (npm install keytar) if the function fails to authenticate using Visual Studio Code Azure extension
    
    // 'keyvault-secrets' package: https://docs.microsoft.com/en-us/javascript/api/@azure/keyvault-secrets/?view=azure-node-latest
    const client = new SecretClient(keyVaultURI, credential);

    const secretName = "MyAppSecret";
    const retrievedSecret = await client.getSecret(secretName);
    context.res = {
        status: 200,
        body: { "secretValue": retrievedSecret.value }
    };
}
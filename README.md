# CypherPunk Culture Wallet
CypherPunk Culture, a term coined in the late 1980s, refers to a community of activists and technologists promoting the use of strong cryptographic tools to enhance privacy and security. This movement has been influential in shaping the modern discourse around digital privacy, encryption, and online anonymity.

[EskyLab](https://github.com/EskyLab)
Fingerprint: BCA7 ECA0 C8A9 AE5D E671  1957 4DFE 7AA4 623B AE21 
[Info CypherPunk Culture](https://github.com/EskyLab/Public-Key/blob/main/public.info-cypherpunkculture.com.asc)
(GPG Public Key)

[![License](https://img.shields.io/badge/license-MIT%2FApache--2.0-blue.svg)](https://github.com/reez/BDKSwiftExampleWallet/blob/main/LICENSE)

An example iOS app using [Bitcoin Dev Kit](https://github.com/bitcoindevkit) (BDK)

<img src="Docs/cypherpunk culture Bitcoin Wallet.png" alt="Screenshot" width="750" height="475">

<img src="Docs/bitcoin-screen.png" alt="Screenshot" width="210.5" height="420">

## Functionality

*This is an experimental work in progress.*

### Wallet

Supports single key HD wallets with BIP86 derivation paths. 

### Implemented

- [x] Create Wallet `Wallet(descriptor: changeDescriptor: network: databaseConfig:)`

- [x] Get Address `getAddress`

- [x] Get Balance `getBalance`

- [x] List Transactions `listTransactions`

- [x] Send `send`

- [x] Sync `sync`

## Swift Packages

- [bdk-swift](https://github.com/bitcoindevkit/bdk-swift)

- [BitcoinUI](https://github.com/reez/BitcoinUI)

- [KeychainAccess](https://github.com/kishikawakatsumi/KeychainAccess)

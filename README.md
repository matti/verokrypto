# Verokrypto

## with docker

```bash
cat execution-history.xlsx | docker run -i mattipaksula/verokrypto process coinex -
```

## with ruby

```bash
gem install verokrypto
```

```bash
verokrypto process coinex execution-history.xlsx
```

### check all

* time utc
* times in correct order
* rows count match
* price available
* highest gains

### coinbase

* eth mining labeled correctly?

### koinly problems

* randomly sorts events with same second and does not support milliseconds
* if amount "0.0" then just silently ignores in import
* csv supports labels like stake and unstake, but those are silently ignored in import

### coinex

coinex has no milliseconds

<https://www.coinex.com/exchange/record>

<https://www.coinex.com/asset/deposit/record>

<https://www.coinex.com/asset/withdraw/record>

### todo

* no transcation id in trades as they are not in blockchain? (no md5)
* southxchange trade fees (other way around?)
* southxchange times vs koinly

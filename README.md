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

### coinex

coinex has no milliseconds

https://www.coinex.com/exchange/record

https://www.coinex.com/asset/deposit/record

https://www.coinex.com/asset/withdraw/record


### todo

* no transcation id in trades as they are not in blockchain? (no md5)

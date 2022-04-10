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


coinex has no milliseconds

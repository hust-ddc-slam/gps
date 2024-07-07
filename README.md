# gps
GPS driver and data decode.


## Decoder
A typical GPS format and decoding:

For a GPGGA line,
```
$GPGGA,065733.20,3031.03113541,N,11425.08672818,E,1,14,2.0,35.2323,M,-13.6735,M,,*7B
```
the ascii and meanings:
```
// $GPGGA
// a timestamp line.
33 30 33 31 2E 30 33 31 30 31 35 38 30 2C (3031.03113541,)
4E 2C (N,)
31 31 34 32 35 2E 30 38 36 37 38 30 33 39 2C (11425.08672818,)
45 2C (E, )
31 2C (1, type)
31 34 2C (14, N)
32 2E. 30 2C (2.0, hdop)
33 35 2E 34 33 37 33 2C (35.2323,)
4D 2C (M,)
2D 31 33 2E. 36 37 33 35 2C (-13.6735,)
4D 2C (M,)
2C (,)
2A (*)
37 33 (sum, 7B)
0D 0A (CR, LF)
```

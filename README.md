# word-search

The executable file `word-search-solver` is your entry point.

Most of the logic is inside the `WordSearch.pm` module.

Unit tests are executed through `unit-tests.pl`.

Example run with pre-generated grid (great test!):

`./word-search-solver --dict test-files/digits-dictionary.txt --grid test-files/digits-grid.txt`

```
s--------------------zerorez-----------e
-e----r----five--five----w-------s-----e
--v----u------------------t--e---i-----r
---e----o-------thgie-------n----x-----h
--nine---f-----------------o-----------t
[r - l2r] ( 0,21) zero
[r - l2r] ( 1,11) five
[r - l2r] ( 1,17) five
[r - l2r] ( 4, 2) nine
[c | t2b] ( 1,33) six
[s \ l2r] ( 0, 0) seven
[z / l2r] ( 4,27) one
[R - r2l] ( 3,20) eight
[R - r2l] ( 0,27) zero
[C | b2t] ( 4,39) three
[S \ r2l] ( 4, 9) four
[S \ r2l] ( 2,26) two
```

Example run with a randomly generated grid, searched only in the left-to-right, downward diagonal direction:

`./word-search-solver --rows 5 -columns 40 --directions s`

```
kpkulnuluvytavjptshxxkwrczyjosxxxvjdqqec
gcufnlvlktauvghegrtcaybfnogwregfyqvkescl
wrbgbxaeweyptuuczjiyxknbwrbfojcvgppxaxwb
jrzavnknfkcwzpxpkxfhomonadvwbgbxulstputc
kwsvtpnatwxnzmsjmcoitsuwxwusfzxstukasyqi
[s \ l2r] ( 3,35) ts
[s \ l2r] ( 3, 1) rs
[s \ l2r] ( 3,22) ow
[s \ l2r] ( 0, 1) pug
[s \ l2r] ( 3,16) kc
[s \ l2r] ( 0,24) cob
[s \ l2r] ( 1, 5) la
[s \ l2r] ( 2, 6) an
[s \ l2r] ( 2, 6) ant
[s \ l2r] ( 3,21) mu
[s \ l2r] ( 3,26) vs
[s \ l2r] ( 2,14) up
[s \ l2r] ( 2,19) yo
[s \ l2r] ( 0,17) sty
[s \ l2r] ( 1,36) ex
[s \ l2r] ( 3,38) ti
[s \ l2r] ( 0, 0) kc
[s \ l2r] ( 3, 3) at
[s \ l2r] ( 2, 2) bat

```

# How to run NPB-debug Programs
## Make the target 

Clean `/bin`, `/CG` and `SP` first.

To make target, take CG.B for example:
```
cp -r CG.B CG
make cg CLASS=B
./bin/cg.B.x
```

Note: encounter compilation error building SP.A and SP.B.

## Run pLiner
For CG.B, change dir to `/CG`, and do 
```
python ../../../../scripts/search.py cg.c "-- -c -I../common -g -Wall -O3 -mcmodel=medium -ffast-math"
```

For SP.A and SP.b, change dir to `/SP`, and do 
```
python ../../../../scripts/search-mul.py mine.csv "-- -c -I../common -g -Wall -O3 -mcmodel=medium -ffast-math"
```
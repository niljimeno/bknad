default:
	ghc main.hs -Wall -o bknad

build:
	ghc main.hs -Wall -o bknad

run:
	ghc main.hs -Wall -o bknad
	./main try/a try/b

clean:
	rm *.hi *.o bknad

install:
	ghc main.hs -Wall -o bknad
	cp bknad /usr/local/bin/

default:
	ghc main.hs -Wall -o bknad

build:
	ghc main.hs -Wall

run:
	# will only work with test files
	ghc main.hs -Wall
	./main try/a try/b

clean:
	rm *.hi *.o bknad

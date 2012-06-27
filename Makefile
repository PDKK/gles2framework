# can be xorg or rpi
PLATFORM=xorg
#PLATFORM=rpi



ifeq ($(PLATFORM),xorg)
	FLAGS=-D__FOR_XORG__ -c -std=gnu99 `pkg-config libpng --cflags` -Iinclude -Isrc-models -Ikazmath/kazmath
	LIBS=-lX11 -lEGL -lGLESv2 `pkg-config libpng --libs` -lm
endif

ifeq ($(PLATFORM),rpi)
	FLAGS=-D__FOR_RPi__ -c -std=gnu99 `pkg-config libpng --cflags` -Iinclude -Isrc-models -Ikazmath/kazmath
	LIBS=-lX11 -lEGL -lGLESv2 `pkg-config libpng --libs` -Llib -lkazmath -lm
endif


# ok.... find all src/*.c replace all .c with .o then replace src\ with o\ - and breath
# this is the framework itself without samples
OBJ=$(shell find src/*.c | sed 's/\(.*\.\)c/\1o/g' | sed 's/src\//o\//g')

# models
OBJ+=$(shell find src-models/*.c | sed 's/\(.*\.\)c/\1o/g' | sed 's/src\//o\//g')

#kazmath
OBJ+=$(shell find kazmath/kazmath/*.c | sed 's/\(.*\.\)c/\1o/g' | sed 's/kazmath\/kazmath\//o\//g')

# because the examples main and simple are seperate from the framework
# there are explicit rules for them
main: $(OBJ) o/main.o
	gcc $^ -o main $(LIBS)

simple: $(OBJ) o/simple.o
	gcc $^ -o simple $(LIBS)

o/main.o: main.c
	gcc $(FLAGS) -Isrc $< -o $@

o/simple.o: simple.c
	gcc $(FLAGS) -Isrc $< -o $@


# used to create object files from all in src directory
o/%.o: src/%.c
	gcc $(FLAGS) $< -o $@

o/%.o: src-models/%.c
	gcc $(FLAGS) $< -o $@

o/%.o: kazmath/kazmath/%.c
	gcc $(FLAGS) $< -o $@


# makes the code look nice!
indent:
	indent -linux src/*.c src/*.h *.c

# deletes all intermediate object files and all compiled
# executables and automatic source backup files
clean:
	rm -f o/*.o
	rm -f src/*~
	rm -f src-models/*~
	rm -f include/*~
	rm -f *~
	rm -f main
	rm -f simple

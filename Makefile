VASM := vasmm68k_mot
VASMFLAGS_DEBUG := -Ftos -nowarn=62 -m68000 -no-fpu -no-opt
VASMFLAGS := -Ftos -nowarn=62 -m68000 -no-fpu -no-opt -nosym
MAIN := logistic.s
TARGET_DEBUG := logistid.tos
TARGET := logistic.tos

.PHONY: all clean debug
all: $(TARGET)
debug: $(TARGET_DEBUG)

$(TARGET): $(wildcard *.s)
		$(VASM) $(VASMFLAGS) $(MAIN) -o $@

$(TARGET_DEBUG): $(wildcard *.s)
		$(VASM) $(VASMFLAGS_DEBUG) $(MAIN) -o $@

clean:
		rm -f $(TARGET)

# Variables
BIN_LIB=CMPSYS
LIBLIST=$(BIN_LIB)
SHELL=/QOpenSys/usr/bin/qsh

# Targets
all: depts.pgm.sqlrpgle employees.pgm.sqlrpgle

# Dependencies
depts.pgm.sqlrpgle: depts.dspf
employees.pgm.sqlrpgle: emps.dspf

# Rules
%.pgm.sqlrpgle: qrpglesrc/%.pgm.sqlrpgle
# Change the file attribute to CCSID 1252
	system -s "CHGATR OBJ('$<') ATR(*CCSID) VALUE(1252)"
# Add the library to the library list and compile the SQLRPGLE source
	liblist -a $(LIBLIST); \
	system "CRTSQLRPGI OBJ($(BIN_LIB)/$*) SRCSTMF('$(shell printf "%q" $<)') COMMIT(*NONE) DBGVIEW(*SOURCE) OPTION($(OPT)) COMPILEOPT('INCDIR(''qrpgleref'')')"

%.dspf:
# Create source physical file if it does not exist
	-system -qi "CRTSRCPF FILE($(BIN_LIB)/QDDSSRC) RCDLEN(112)"
# Copy the DSPF source member from the IFS to the QDDSSRC file in the library
	system "CPYFRMSTMF FROMSTMF('$(shell printf "%q" ./qddssrc/$*.dspf)') TOMBR('/QSYS.lib/$(BIN_LIB).lib/QDDSSRC.file/$*.mbr') MBROPT(*REPLACE)"
# Create the display file
	system -s "CRTDSPF FILE($(BIN_LIB)/$*) SRCFILE($(BIN_LIB)/QDDSSRC) SRCMBR($*)"
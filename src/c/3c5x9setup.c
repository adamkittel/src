/* 3c5x9setup.c: Setup program for 3Com EtherLink III ethercards.

   Copyright 1994-1996 by Donald Becker.
   This version released under the Gnu Public Lincese, incorporated herein
   by reference.  Contact the author for use under other terms.

   This is a EEPROM setup and diagnostic program for the 3Com 3c5x9 series
   ethercards.

   This program must be compiled with "-O"!  See the bottom of this file
   for the suggested compile-command.

   The author may be reached as becker@cesdis.gsfc.nasa.gov.
   C/O USRA-CESDIS, Code 930.5 Bldg. 28, Nimbus Rd., Greenbelt MD 20771
*/

static char *version_msg =
"3c5x9setup.c:v0.04 12/11/96 Donald Becker (becker@cesdis.gsfc.nasa.gov)\n";
static char *usage_msg =
"Usage: 3c5x9 [-aEfFsvVw] [-p <IOport>] [-F 10baseT|10base2|AUI>] [-Q <IRQ>]\n";

#include <unistd.h>
#include <stdio.h>
#include <stdlib.h>
#include <getopt.h>
#include <strings.h>
#include <linux/in.h>
#include <asm/io.h>

struct option longopts[] = {
 /* { name  has_arg  *flag  val } */
	{"base-address", 1, 0, 'p'},
	{"new-base-address", 1, 0, 'P'},
	{"show_all_registers",	0, 0, 'a'},	/* Print all registers. */
	{"help",	0, 0, 'h'},	/* Give help */
	{"emergency-rewrite",  0, 0, 'E'}, /* Re-write a corrupted EEPROM.  */
	{"force-detection",  0, 0, 'f'},
	{"new-interface",  1, 0, 'F'},	/* New interface (built-in, AUI, etc.) */
	{"new-IOaddress",	1, 0, 'P'},	/* New base I/O address. */
	{"new-irq",	1, 0, 'Q'},		/* New interrupt number */
	{"verbose",	0, 0, 'v'},		/* Verbose mode */
	{"version", 0, 0, 'V'},		/* Display version number */
	{"write-EEPROM", 1, 0, 'w'},/* Actually write the EEPROM with new vals */
	{ 0, 0, 0, 0 }
};

/* Offsets from base I/O address. */
#define EL3_DATA 0x00
#define EL3_CMD 0x0e
#define EL3_STATUS 0x0e

#define	 EEPROM_READ 0x80
#define	 EEPROM_WRITE 0x40
#define	 EEPROM_ERASE 0xC0
#define	 EEPROM_EWENB 0x30		/* Enable erasing/writing for 10 msec. */
#define	 EEPROM_EWDIS 0x00		/* Enable erasing/writing for 10 msec. */

#define EL3WINDOW(win_num) outw(0x0800+(win_num), ioaddr + EL3_CMD)

/* Register window 1 offsets, used in normal operation. */
#define TX_FREE 0x0C
#define TX_STATUS 0x0B
#define TX_FIFO 0x00
#define RX_FIFO 0x00

/* EEPROM operation locations. */
enum eeprom_offset {
	PhysAddr01=0, PhysAddr23=1, PhysAddr45=2, ModelID=3,
	EtherLink3ID=7, IFXcvrIO=8, IRQLine=9,
	AltPhysAddr01=10, AltPhysAddr23=11, AltPhysAddr45=12,
	DriverTune=13, Checksum=15};

/* Last-hope recovery major boo-boos: rewrite the EEPROM with the values
   from my card (and hope I don't met you on the net...). */
unsigned short djb_eeprom[16] = {
	0x0020, 0xaf0e, 0x3bc2, 0x9058, 0xbc4e, 0x0036, 0x4441, 0x6d50,
	0x0090, 0xaf00, 0x0020, 0xaf0e, 0x3bc2, 0x1310, 0x0000, 0x343c, }; 
/* Values read from the EEPROM, and the new image. */
unsigned short eeprom_contents[16];
unsigned short new_ee_contents[16];

int do_write_eeprom = 0;
int ioaddr;

static void print_eeprom(unsigned short *eeprom_contents);
static void write_eeprom(short ioaddr, int index, int value);
static unsigned int calculate_checksum(unsigned short *values);
static int do_update(unsigned short *ee_values,
					 int index, char *field_name, int new_value);

int
main(int argc, char **argv)
{
	int port_base = 0x300;
	int new_interface = -1, new_irq = -1, new_ioaddr = -1;
	int errflag = 0, opt_f = 0, verbose = 0, show_version = 0;
	int emergency_rewrite = 0;
	int dump_all_regs = 0;
	int c, longind, i, j, saved_window;
	extern char *optarg;

	while ((c = getopt_long(argc, argv, "aEfF:i:p:P:Q:svVw",
							longopts, &longind))
		   != -1)
		switch (c) {
		case 'a': dump_all_regs++;		 break;
		case 'E': emergency_rewrite++;	 break;
		case 'f': opt_f++; break;
		case 'F':
			if (strncmp(optarg, "10base", 6) == 0) {
				switch (optarg[6]) {
				case 'T':  new_interface = 0; break;
				case '2':  new_interface = 3; break;
				case '5':  new_interface = 1; break;
				default: errflag++;
				}
			} else if (strcmp(optarg, "AUI") == 0)
				new_interface = 1;
			else if (optarg[0] >= '0' &&  optarg[0] <= '3'
					   &&  optarg[1] == 0)
				new_interface = optarg[0] - '0';
			else {
				fprintf(stderr, "Invalid interface specified: it must be"
						" 0..3, '10base{T,2,5}' or 'AUI'.\n");
				errflag++;
			}
			break;
		case 'Q':
			new_irq = atoi(optarg);
			if (new_irq < 3 || new_irq > 15 || new_irq == 6 || new_irq == 8) {
				fprintf(stderr, "Invalid new IRQ %#x.  Valid values: "
						"3-5,7,9-15.\n", new_irq);
				errflag++;
			}
			break;
		case 'p':
			port_base = strtol(optarg, NULL, 16);
			break;
		case 'P':
			new_ioaddr = strtol(optarg, NULL, 16);
			if (new_ioaddr < 0x200 || new_ioaddr > 0x3f0) {
				fprintf(stderr, "Invalid new I/O address %#x.  Valid range "
						"0x200-0x3f0.\n", new_ioaddr);
				errflag++;
			}
			break;
		case 'v': verbose++;		 break;
		case 'V': show_version++;		 break;
		case 'w': do_write_eeprom++;	 break;
		case '?':
			errflag++;
		}
	if (errflag) {
		fprintf(stderr, usage_msg);
		return 3;
	}

	if (ioperm(port_base, 16, 1) < 0) {
		perror("3c5x9setup: ioperm()");
		fprintf(stderr, "This program must be run as root.\n");
		return 2;
	}

	if (verbose)
		printf(version_msg);

	ioaddr = port_base;

	saved_window = inw(ioaddr + EL3_STATUS);
	if (!opt_f  && (saved_window & 0xe000) == 0x2000) {
		printf("A potential 3c5*9 has been found, but it appears to still "
			   "be active.\nEither shutdown the network, or use the"
			   " '-f' flag.\n");
		return 1;
	}

	EL3WINDOW(0);
	if (inw(port_base) == 0x6d50) {
		printf("3c5x9 found at %#3.3x.\n", port_base);
	} else {
		printf("3c5*9 not found at %#3.3x, status %4.4x.\n"
			   "If there is a 3c5*9 card in the machine, explicitly set the"
			   " I/O port address\n  using '-p <ioaddr>\n",
			   port_base, inw(port_base));
		if (opt_f < 2)
			return 1;
	}

	if (dump_all_regs) {
		for (j = 0; j < 8; j++) {
			int i;
			printf("Window %d:", j);
			outw(0x0800 + j, ioaddr + 0x0e);
			for (i = 0; i < 16; i+=2)
				printf(" %4.4x", inw(ioaddr + i));
			printf(".\n");
		}
	}

	EL3WINDOW(0);

	/* Read the EEPROM. */
	for (i = 0; i < 16; i++) {
		outw(EEPROM_READ + i, ioaddr + 10);
		/* Pause for at least 162 us. for the read to take place. */
		usleep(162);
		eeprom_contents[i] = inw(ioaddr + 12);
		if (verbose)
			printf("EEPROM index %d: %4.4x.\n", i, eeprom_contents[i]);
	}

	if (emergency_rewrite) {
		if (emergency_rewrite < 3  ||  !do_write_eeprom)
			printf(" Caution!  Last-chance EEPROM write requested.  The\n"
				   " new EEPROM values will not be written without"
				   " '-E -E -E -w' flags.\n");
		else {
			for (i = 0; i < 16; i++) {
				eeprom_contents[i] = djb_eeprom[i];
				write_eeprom(ioaddr, i, eeprom_contents[i]);
			}
		}
	}
	{
		unsigned short new_ifxcvrio = eeprom_contents[IFXcvrIO];
		unsigned short new_irqline = eeprom_contents[IRQLine];
		int something_changed = 0;

		if (new_interface >= 0)
			new_ifxcvrio = (new_interface << 14) | (new_ifxcvrio & 0x3fff);
		if (new_ioaddr > 0)
			new_ifxcvrio = ((new_ioaddr>>4) & 0x1f) | (new_ifxcvrio & 0xffe0);
		if (new_irq > 0)
			new_irqline = (new_irq << 12) | 0x0f00;

		if (do_update(eeprom_contents, IRQLine, "IRQ", new_irqline))
			something_changed++;

		if (do_update(eeprom_contents, IFXcvrIO, "transceiver/IO",
					  new_ifxcvrio))
			something_changed++;

		/* To change another EEPROM value write it here. */

		if (do_update(eeprom_contents, Checksum, "checksum",
					  calculate_checksum(eeprom_contents)))
			something_changed++;

		if (something_changed  &&  !do_write_eeprom)
			printf(" (The new EEPROM values will not be written without"
					" the '-w' flag.)\n");
	}

	print_eeprom(eeprom_contents);

	EL3WINDOW(saved_window>>13);

	return 0;
}

static void print_eeprom(unsigned short *eeprom_contents)
{
	unsigned char *phys_addr;
	char *if_names[] = {"10baseT", "AUI", "undefined", "BNC"};
	int i;

	printf("Model number 3c%2.2x%1.1x version %1.1x, base I/O %#x,"
		   " IRQ %d, %s port.\n",
		   eeprom_contents[ModelID] & 0x00ff,
		   eeprom_contents[ModelID] >> 12,
		   (eeprom_contents[ModelID] >> 8) & 0x000f,
		   0x200 + ((eeprom_contents[IFXcvrIO] & 0x1f) << 4),
		   eeprom_contents[IRQLine] >> 12,
		   if_names[eeprom_contents[IFXcvrIO] >> 14]);

	phys_addr = (unsigned char *)(eeprom_contents + PhysAddr01);
	printf("Primary physical address is %2.2x", phys_addr[1]);
	for (i = 1; i < 6; i++)
		printf(":%2.2x", phys_addr[i^1]);

	phys_addr = (unsigned char *)(eeprom_contents + AltPhysAddr01);
	printf("\nAlternate physical address is %2.2x", phys_addr[1]);
	for (i = 1; i < 6; i++)
		printf(":%2.2x", phys_addr[i^1]);
	printf("\n");

	if (calculate_checksum(eeprom_contents) != eeprom_contents[Checksum])
		printf("****CHECKSUM ERROR****: Calcuated checksum: %4.4x, "
			   "stored checksum %4.4x.\n",
			   calculate_checksum(eeprom_contents),
			   eeprom_contents[Checksum]);
}


static void write_eeprom(short ioaddr, int index, int value)
{
	outw(value, ioaddr + 12);
	outw(EEPROM_EWENB, ioaddr + 10);
	usleep(60);
	outw(EEPROM_ERASE + index, ioaddr + 10);
	usleep(60);
	outw(EEPROM_EWENB, ioaddr + 10);
	usleep(60);
	outw(value, ioaddr + 12);
	outw(EEPROM_WRITE + index, ioaddr + 10);
	usleep(10000);
}

/* Calculate the EEPROM checksum.
   The checksum for the fixed values is returned in the high byte.
   The checksum for the programmable variables is in the low the byte.
   */

static unsigned int
calculate_checksum(unsigned short *values)
{
	int fixed_checksum = 0, var_checksum = 0;
	int i;

	for (i = 0; i <= 14; i++) {				/* Note: 14 (loc. 15 is the sum) */
		if (i == IFXcvrIO || i == IRQLine || i == DriverTune)
			var_checksum ^= values[i];
		else
			fixed_checksum ^= values[i];
	}
	return ((fixed_checksum ^ (fixed_checksum << 8)) & 0xff00) |
		((var_checksum ^ (var_checksum >> 8)) & 0xff);
}

static int do_update(unsigned short *ee_values,
					 int index, char *field_name, int new_value)
{
	if (ee_values[index] != new_value) {
		if (do_write_eeprom) {
			printf("Writing new %s entry 0x%4.4x.\n",
				   field_name, new_value);
			write_eeprom(ioaddr, index, new_value);
		} else
			printf(" Would write new %s entry 0x%4.4x (old value 0x%4.4x).\n",
				   field_name, new_value, ee_values[index]);
		ee_values[index] = new_value;
		return 1;
	}
	return 0;
}


/*
 * Local variables:
 *  compile-command: "cc -N -O -Wall -o 3c5x9 3c5x9setup.c"
 *  tab-width: 4
 *  c-indent-level: 4
 * End:
 */

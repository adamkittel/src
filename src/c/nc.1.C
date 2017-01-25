#include <curses.h>
#include <signal.h>
 
       static void finish(int sig);
 
       main(int argc, char *argv[])
       {
           /* initialize your non-curses data structures here */
	 int a;
           (void) signal(SIGINT, finish);      /* arrange interrupts to terminate */
 
           (void) initscr();      /* initialize the curses library */
           keypad(stdscr, TRUE);  /* enable keyboard mapping */
           (void) nonl();         /* tell curses not to do NL->CR/NL on output */
           (void) cbreak();       /* take input chars one at a time, no wait for \n */
           (void) noecho();       /* don't echo input */
 
 
           for (a=0;a<10;a++)
           {
               int c = getch();     /* refresh, accept single keystroke of input */
 
               /* process the command keystroke */
           }
 
           finish(0);               /* we're done */
       }
 
       static void finish(int sig)
       {
           endwin();
 
           /* do your non-curses wrapup here */
 
           exit(0);
       }

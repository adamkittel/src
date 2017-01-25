#include <iostream.h>
#include <fstream.h>

main()
{
  fstream MAILFILE("/home/akittel/namail/Inbox",ios::in|ios::beg);
  char FROM[]="From ";
  char SKIPLINE[6];
  do
    {
      MAILFILE.get(SKIPLINE,5,'\n');
      cout<<SKIPLINE;
    } while(strcmp(SKIPLINE,FROM) != 0);
return 0;
}
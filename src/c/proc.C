// this is a comment
// don't FUCK with my code
// freely redistributeable
// this app opens proctools

#include <iostream.h>
#include <stdlib.h>
#include <string.h>
#include <netdb.h>

main(int argc, char **agrv, char **envp)
{
  char Proctool[71];
  
  char *ProdMachines[] = {
    "den-adr1" ,"den-bill1","den-cst1" ,"den-cst2",
    "den-disp1","den-eq1"  ,"den-help1","den-mon1","den-xref1",
    "den-xref2","den-aruc1","den-oars1","den-dds1","den-dds2",
  };

  char *DevMachines[] = {
    "animas",  "arkansas","den1",  "den2",    "dal2",
    "gunnison","mancos",  "poudre","colorado","blab1","conejas"
  };
  
  char Host[5];
  int a;
  
  cout << gethostbyname(DevMachines[1]);
  if(argc == 1)
    { 
      cout << "\nArgument count = "<<a
	   << "\nUsage proc hostname (optional)machine name\n"
	   << "\n********EXITING********"<<endl;
      exit(1);
    }
 
  if(argc == 2)
    {
      //******** start production machines ********
     for(a=0;a<15;a++)
      {
	  sprintf(Proctool,
		  "rsh -n -l oper %s \"export DISPLAY=den-ops3:0 ; /opt/sa/bin/proctool &\" &"
		  ,ProdMachines[a]);
	  cout << Proctool
	       << "\n"
	       <<endl;//system(Proctool);
      }
    }
return 0;
}
    
    

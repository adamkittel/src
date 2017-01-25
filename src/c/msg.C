// iam writing this in c++ because i
// got fed up with perl

#include <iostream.h>
#include <fstream.h>

main()
{
  fstream HOSTSFILE("/home/oper/bin/.hosts.list",ios::in | ios::beg);
  int i=0;
  char HOSTNAME[21];

  while(!HOSTSFILE.eof())
    {
      HOSTSFILE.getline(HOSTNAME,20);
      cout<<HOSTNAME<<endl;
      i++;
    }
return 0;
}

  


// this is a comment

#include <stdio.h>
#include <iostream.h>
#include <time.h>
#include <fstream.h>
#include <stdlib.h>
#include <string.h>
char *Date();
char *Day();
BkupFile(char *System);

char *Date()//******** prints date string Mon Jun  3 13:46:20 1996
{  
  time_t tmptr;
  tmptr=time(NULL);
  char *buff[80];
  //  sprintf(buff,"%s",ctime(&tmptr));
  //  buff=(ctime(&tmptr));
  strftime(buff, sizeof buff, "%a, %b, %d, %H,:%M,:%S", localtime(&tmptr));
  return buff;
}

char *Day()//******** prints the day of the month
{
  time_t tmptr;
  char buff[3];
  tmptr=time(NULL);
  strftime(buff, sizeof buff, "%d", localtime(&tmptr));
  return buff; 
}



main() 
{
  fstream BkupFile;
  int a;
  //  char *day=Day();
  //  char *date=Date();
  char BkupDir[]=       "/var/log/backup/ufsbackup.";
  char Rsh1[] =         "rsh den-";
  char Rsh3[] =         " -l oper \"cat /var/log/full_backup.";
  char Rsh5[] =         " >> $HOME/bin/prod_backup.log\"";
  char Rcp1[] =         "rcp ";
  
  char BkupFileName[] = "$HOME/bin/prod_backup.log";

  char *ErrorString[] = {
                        "error","offline","abort", "busy","denied",
                        "[Tt]imed out","No such","No.*tape"};
  char *ProgressString[] = {
                        "internal","stacker","load","Log","DONE","Host",
                        "Backups.*complet"};
  char *MachineList[] = {
                        "adr1","aruc1","bill1","cst1","dds1","dds2",
                        "disp1","eq1","oars1","xref1","help1","mon1","cppv1"};
  

  /*strcat(Rsh1,MachineList[0]);
strcat(Rsh1, Rsh3);
strcat(Rsh1,day);
strcat(Rsh1,Rsh5);
cout<<Rsh1<<endl;*/

cout<<"****************"<<endl;
cout<<Day()<<endl;
cout<<"****************"<<endl;

return 0;
}

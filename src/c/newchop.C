// WARNING!!! THIS CODE IS STILL DIRTY
// this will sort out the annoying rsm and cron mail
// compile command: c++ -o mailchop -g mailchop.C
// this has only been tested with netscape mail
// this app will read your nsmail/Inbox file
// and create 2 other files; InBox & Junk
// you may reciece a warning when you read the 
// new files, but don't be alarmed.
// IT'S ALL LIES

#include <iostream.h>
#include <fstream.h>
#include <string.h>

  fstream WASTE("Junk",ios::trunc|ios::app);
  fstream INBOX("InBox",ios::trunc|ios::app);
// you may want change the below file to /var/mail/<username>
  fstream MAILFILE("/home/akittel/nsmail/Inbox",ios::in|ios::beg);
//  fstream ATTACH("Attach",ios::trunc|ios::app);

class ReadInbox 
{
  int A;
  int B;
  char LINE[21][201]; 
  char TEMPLINE[28];
  char LASTLINE[201];
  char ATTACHMENT1[14];
  char ATTACHMENT2[7];
  char ATTACHMENT3[14];
  char WASTE1[14];
  char WASTE2[14];
  char WASTE3[5];
  char WASTE4[9];
  char FROM[6];
public:
  ReadInbox();
  int ReadHeader();
  void WriteInbox();
  void WriteWaste();
  void SkipAttachment();
  void ClearLine(int W);
};

ReadInbox::ReadInbox()
{
  int C;
  int D;
  
   ATTACHMENT1="multipart/mix";
   ATTACHMENT2="attach";
   ATTACHMENT3="X-sun-attachm";
   WASTE1="Mailer-Daemon";
   WASTE2="oper@den-mon1";
   WASTE3="root";
   WASTE4="smmtoper";
   FROM="From "; 
   while(!MAILFILE.eof())
     {
       C = ReadHeader();
       cout<<"Message "<<D<<" ";
       switch(C)
	 {
	 case 1:cout<<"Attachment"<<endl; SkipAttachment(); break;
	 case 2:cout<<"Attachment"<<endl; SkipAttachment(); break;
	 case 3:cout<<"Attachment"<<endl; SkipAttachment(); break;
	 case 4:cout<<"Junk Mail"<<endl; WriteWaste(); break;
	 case 5:cout<<"Junk Mail"<<endl; WriteWaste(); break;
	 case 6:cout<<"Junk Mail"<<endl; WriteWaste(); break;
	 case 7:cout<<"Junk Mail"<<endl; WriteWaste(); break;
	 default:cout<<"Regular Mail"<<endl; WriteInbox(); break;
	 }
       D++;
     }
}

ReadInbox::ReadHeader()
{
  if(strstr(LASTLINE,ATTACHMENT1) != NULL) {B = 1; return B;}
  if(strstr(LASTLINE,ATTACHMENT2) != NULL) {B = 2; return B;}
  if(strstr(LASTLINE,ATTACHMENT3) != NULL) {B = 3; return B;}
  if(strstr(LASTLINE,WASTE1) != NULL) {B = 4; return B;}
  if(strstr(LASTLINE,WASTE2) != NULL) {B = 5; return B;}
  if(strstr(LASTLINE,WASTE3) != NULL) {B = 6; return B;}
  if(strstr(LASTLINE,WASTE4) != NULL) {B = 7; return B;}

      for(A=1;A<=21;A++)
	{
	  MAILFILE.getline(LINE[A],500);
	  //cout<<"processing line "<<A<<endl<<LINE[A]<<endl;
	  if(strstr(LINE[A],ATTACHMENT1) != NULL) {B = 1; return B;}
	  if(strstr(LINE[A],ATTACHMENT2) != NULL) {B = 2; return B;}
	  if(strstr(LINE[A],ATTACHMENT3) != NULL) {B = 3; return B;}
	  if(strstr(LINE[A],WASTE1) != NULL) {B = 4; return B;}
	  if(strstr(LINE[A],WASTE2) != NULL) {B = 5; return B;}
	  if(strstr(LASTLINE,WASTE3) != NULL) {B = 6; return B;}
	  if(strstr(LASTLINE,WASTE4) != NULL) {B = 7; return B;}
	}

  B = 0;
  return B;
}

void ReadInbox::ClearLine(int W)
{
 strcpy(LINE[W]," ");
}

void ReadInbox::WriteInbox()
{
  int Z;
  char WRITELINE[201];

  INBOX<<LASTLINE<<endl;
  cout<<"Writting Inbox "<<LASTLINE<<endl<<endl;
  for(Z=1;Z<=A;Z++)
    {
      INBOX<<LINE[Z]<<endl;
      ClearLine(Z);
    }
  while(!MAILFILE.eof())
    {
      MAILFILE.getline(WRITELINE,201);
      if(strncmp(WRITELINE,FROM,5) == 0)
	{ break; 
	} else {
	  INBOX<<WRITELINE<<endl;
	}
    }
  LASTLINE=WRITELINE;
  cout<<"InBox LastLine"<<LASTLINE<<endl;
  A = 0;
}

void ReadInbox::WriteWaste()
{
  char WASTELINE[201];
  int Z;
  
  WASTE<<LASTLINE<<endl;
  cout<<"Writting Waste "<<LASTLINE<<endl<<endl;
  for(Z=1;Z<=A;Z++)
    {
      WASTE<<LINE[Z]<<endl;
      ClearLine(Z);
    }

  while(!MAILFILE.eof())
    {
      MAILFILE.getline(WASTELINE,201);
      if(strncmp(WASTELINE,FROM,5) == 0)
	{ break; 
	} else {
      WASTE<<WASTELINE<<endl;
	}
    }
  LASTLINE=WASTELINE;
  cout<<"Waste LastLine"<<LASTLINE<<endl;
  A = 0;
}


void ReadInbox::SkipAttachment()
{
  char SKIPLINE[74];
  char CH;
  int X;
  int step;
  
  INBOX<<LASTLINE<<endl;
  cout<<"Writting Attachment "<<LASTLINE<<endl<<endl;
  for(X=1;X<=A;X++)
    {
      INBOX<<LINE[X]<<endl;
      ClearLine(X);
    }

  X=0;
  while(!MAILFILE.eof())
    {
      MAILFILE.get(CH);
      if(strstr(SKIPLINE,FROM) != NULL) 
	{ break;
	} else {
	  cout<<CH;
	  SKIPLINE[X]=CH;
	  X++;
	}
      if(X==73)
	{
	  //INBOX<<SKIPLINE;
	  X=0;	  
	} 
    }
  strncpy(LASTLINE,SKIPLINE,20);
  cout<<"Attachment LastLine"<<LASTLINE<<endl;
  A = 0;
}
	
main()
{
  ReadInbox go;

  WASTE.close();
  INBOX.close();
  MAILFILE.close();
  return 0;
}


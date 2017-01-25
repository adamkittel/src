// WARNING!!! THIS CODE IS STILL DIRTY
// this will sort out the annoying rsm and cron mail
// compile command: c++ -o mailchop -g mailchop.C
// this has only been tested with netscape mail


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
  char ATTACHMENT1[28];
  char ATTACHMENT2[28];
  char ATTACHMENT3[28];
  char WASTE1[28];
  char WASTE2[28];
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
   ATTACHMENT1="Content-Type: multipart/mix";
   ATTACHMENT2="Content-Disposition: attach";
   ATTACHMENT3="Content-Type: X-sun-attachm";
   WASTE1="From Mailer-Daemon@den-mon1";
   WASTE2="From oper@den-mon1.tcinc.co";
   FROM="From "; 
   while(!MAILFILE.eof())
     {
       C = ReadHeader();
       switch(C)
	 {
	 case 1:cout<<ATTACHMENT1<<endl; SkipAttachment(); break;
	 case 2:cout<<ATTACHMENT2<<endl; SkipAttachment(); break;
	 case 3:cout<<ATTACHMENT3<<endl; SkipAttachment(); break;
	 case 4:cout<<WASTE1<<endl; WriteWaste(); break;
	 case 5:cout<<WASTE2<<endl; WriteWaste(); break;
	 default:cout<<"REGULAR MAIL"<<endl; WriteInbox(); break;
	 }
     }
}

ReadInbox::ReadHeader()
{
  if(strncmp(LASTLINE,ATTACHMENT1,26) == 0) {B = 1; return B;}
  if(strncmp(LASTLINE,ATTACHMENT2,26) == 0) {B = 2; return B;}
  if(strncmp(LASTLINE,ATTACHMENT3,26) == 0) {B = 3; return B;}
  if(strncmp(LASTLINE,WASTE1,26) == 0) {B = 4; return B;}
  if(strncmp(LASTLINE,WASTE2,26) == 0) {B = 5; return B;}

      for(A=1;A<21;A++)
	{
	  MAILFILE.getline(LINE[A],500);
	  //cout<<"processing line "<<A<<endl<<LINE[A]<<endl;
	  if(strncmp(LINE[A],ATTACHMENT1,26) == 0) {B = 1; return B;}
	  if(strncmp(LINE[A],ATTACHMENT2,26) == 0) {B = 2; return B;}
	  if(strncmp(LINE[A],ATTACHMENT3,26) == 0) {B = 3; return B;}
	  if(strncmp(LINE[A],WASTE1,26) == 0) {B = 4; return B;}
	  if(strncmp(LINE[A],WASTE2,26) == 0) {B = 5; return B;}
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
  for(Z=0;Z<=A;Z++)
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
  A = 0;
}

void ReadInbox::WriteWaste()
{
  char WASTELINE[201];
  int Z;
  WASTE<<LASTLINE<<endl;

  for(Z=0;Z<=A;Z++)
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
  A = 0;
}


void ReadInbox::SkipAttachment()
{
  char SKIPLINE[74];
  char CH;
  int X;
  int step;
  
  ATTACH<<LASTLINE<<endl;
  for(X=0;X<=A;X++)
    {
      ATTACH<<LINE[X]<<endl;
      ClearLine(X);
    }

  X=0;
  while(!MAILFILE.eof())
    {
      MAILFILE.get(CH);
      if(strstr(SKIPLINE,FROM) != NULL) 
	{ break;
	} else {
	  //cout<<CH;
	  SKIPLINE[X]=CH;
	  X++;
	}
      if(X==20)
	{
	  ATTACH<<SKIPLINE;
	  X=0;	  
	}
    }
  strncpy(LASTLINE,SKIPLINE,20);
  //cout<<LastLine<<endl;
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


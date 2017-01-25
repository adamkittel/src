
// this will sort out the annoying rsm and cron mail

#include <iostream.h>
#include <fstream.h>
#include <string.h>

main()
{
  int A = 0;
  char LINE[501];
  char INLINE[501];

  fstream MAILFILE("/home/akittel/nsmail/Inbox",ios::in|ios::out|ios::beg);
  fstream INBOX("INBOX",ios::trunc);
  fstream RSMMAIL("RSM",ios::trunc);
  while(MAILFILE.getline(LINE,500))
	{
	  if(strstr(LINE,"oper@den-mon1.tcinc.com") != NULL)
	    {
	      RSMMAIL<<"\n\n\n"<<LINE<<endl;
	      while(MAILFILE.getline(LINE,500))
		    {
		      if(strstr(LINE,"From ") == NULL)
			{
			  RSMMAIL<<LINE<<endl;
			} else {
			  break;
			}
		    }

	    } else {
	      INBOX<<LINE<<endl;
	      cout<<A<<" Lines processed"<<endl;
	      A++;
	    }
	}
RSMMAIL.close();
INBOX.close();
MAILFILE.close();
return 0;
}

using System;
using Selenium;
namespace SeleniumTest
{
    class Console
    {
        static void Main(string[] args)
        {
            ISelenium sel = new DefaultSelenium(
              "localhost", 4444, "*iehta", "http://www.google.com");
            sel.Start();
            sel.Open("http://www.google.com/");
            sel.Type("q", "FitNesse");
            sel.Click("btnG");
            sel.WaitForPageToLoad("3000");            
        }
    }
}

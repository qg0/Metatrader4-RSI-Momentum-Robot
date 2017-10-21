//+------------------------------------------------------------------+
//|                                        RsiMmtRobot.mq4 |
//|                     Copyright 2017, investdata.000webhostapp.com |
//|                             https://ichimoku-expert.blogspot.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2017, investdata.000webhostapp.com"
#property link      "https://ichimoku-expert.blogspot.com"
#property version   "1.00"
#property strict

bool enableFileLog=false;
int file_handle=INVALID_HANDLE; // File handle
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//string exportPath = "C:\\Users\\InvesdataSystems\\Documents\\NetBeansProjects\\investdata\\public_html\\alerts\\data_history";

int OnInit()
  {
   printf("exportDir = "+TerminalInfoString(TERMINAL_COMMONDATA_PATH));
   MqlDateTime mqd;
   TimeCurrent(mqd);
   string timestamp=string(mqd.year)+IntegerToString(mqd.mon,2,'0')+IntegerToString(mqd.day,2,'0')+IntegerToString(mqd.hour,2,'0')+IntegerToString(mqd.min,2,'0')+IntegerToString(mqd.sec,2,'0');

   if(enableFileLog)
     {
      string strPeriod=EnumToString((ENUM_TIMEFRAMES)Period());
      StringReplace(strPeriod,"PERIOD_","");
      file_handle=FileOpen(Symbol()+"_"+strPeriod+"_"+timestamp+"_backup.csv",FILE_CSV|FILE_WRITE|FILE_ANSI|FILE_COMMON);
      if(file_handle>0)
        {
         string sep=",";
         FileWrite(file_handle,"Timestamp"+sep+"Name"+sep+"Buy"+sep+"Sell"+sep+"Spread"+sep+"Broker"+sep+"Period"+sep+"RSI"+sep+"Momentum");
        }
      else
        {
         printf("error : "+GetLastError());
        }
     }

   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {

   ObjectDelete(0,"Text");

   if(enableFileLog)
     {
      FileClose(file_handle);
     }

/*if (reason==3){
      printf("deinit reason = REASON_CHARTCHANGE");
   }*/

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

MqlDateTime mqd_ot;
MqlTick last_tick_ot;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnTick()
  {
   //int oht = OrdersHistoryTotal();
   //printf("Orders Hitsory Total = " + IntegerToString(oht));
  
   string sname=Symbol();

   MqlTick last_tick;
   double prix_achat;
   double prix_vente;
   double spread;

   bool positionFound=false; // To scan for open positions for current symbol
   int total=OrdersTotal();
   for(int pos=0;pos<total;pos++)
     {
      if(OrderSelect(pos,SELECT_BY_POS)==false) continue;
      //printf(OrderTicket()+" "+OrderOpenPrice()+" "+OrderOpenTime()+" "+OrderSymbol()+" "+OrderLots());

      bool closeOrderIfProfitOver=false;
      if(OrderProfit()>1)
        {
         if(closeOrderIfProfitOver)
           {
            bool b=OrderClose(OrderTicket(),0.1,prix_achat,0,Red);
           }
        }

      if(OrderSymbol()==sname)
        {
         positionFound=true;
        }
     }

   if(positionFound==false)
     {

      double rsi14=iRSI(sname,Period(),14,PRICE_CLOSE,0);
      double rsi14prev=iRSI(sname,Period(),14,PRICE_CLOSE,1);
      double m=iMomentum(sname,Period(),14,PRICE_CLOSE,0);
      double mprev=iMomentum(sname,Period(),14,PRICE_CLOSE,1);

      if(
          (rsi14>=60) && (rsi14prev<60)
          && (m>=100)
         )
        {
         //printf("Will buy now");

         SymbolInfoTick(sname,last_tick);
         prix_achat = last_tick.ask;
         prix_vente = last_tick.bid;

         double stoploss=0;//prix_achat - 0.00300;//prix_achat-0.00100;
         double takeprofit=prix_achat+spread+0.00300/8;

         bool enableTrading=true;
         if(enableTrading)
           {
            int ticket=OrderSend(sname,OP_BUY,0.5,prix_achat,3,stoploss,takeprofit,"My order",16384,0,clrGreen);
            if(ticket<0)
              {
               Print(sname+" : OrderSend failed with error #",GetLastError());
               printf("pa=" + DoubleToString(prix_achat));
              }
            else
               Print(sname+" : OrderSend placed successfully");
           }

        }

     }

  }
//+------------------------------------------------------------------+
//| Timer function                                                   |
//+------------------------------------------------------------------+

void OnTimer()
  {
  }
//+------------------------------------------------------------------+
//| Tester function                                                  |
//+------------------------------------------------------------------+
double OnTester()
  {
//---
   double ret=0.0;
//---

//---
   return(ret);
  }
//+------------------------------------------------------------------+
//| ChartEvent function                                              |
//+------------------------------------------------------------------+
void OnChartEvent(const int id,
                  const long &lparam,
                  const double &dparam,
                  const string &sparam)
  {
//---

  }
//+------------------------------------------------------------------+

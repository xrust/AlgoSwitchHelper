//+------------------------------------------------------------------+
//|                                        AlgoSwitchHelper.mq4 |
//|           Copyright © 2026, Rustamzhan Salidzhanov Aka foreXrust |
//|                                           https://mt-remote.app/ |
//+------------------------------------------------------------------+
//|  Switches the "Algo Trading" button of the terminal on or off.   |
//|  It is an Expert Advisor only because a template can hold an     |
//|  Expert Advisor and cannot hold a script: another Expert opens   |
//|  a chart, applies a template with this helper to it, the helper  |
//|  presses the button once and closes the chart.                   |
//|                                                                  |
//|  It needs "Allow DLL imports": it sends one window message       |
//|  (WM_COMMAND) to the main window of the terminal it runs in,     |
//|  exactly what a click on the button does. Nothing else is        |
//|  touched, nothing leaves the computer, it never trades.          |
//|                                                                  |
//|  Mode: 0 switch off, 1 switch on, 2 toggle. The state is looked  |
//|  at first, so "off" on an already off button does nothing.       |
//|  Mode 3 (the default) does nothing and stays on the chart (to    |
//|  save a template with it).                                       |
//|                                                                  |
//|  The result is left in the terminal's global variables:          |
//|    MTX_ALGO_STATE  1 trading allowed, 0 not (after the helper)   |
//|    MTX_ALGO_TIME   local time of the end of the work             |
//+------------------------------------------------------------------+
#property copyright "Rustamzhan Salidzhanov"
#property link      "https://mt-remote.app/"
#property version   "1.00"
#property strict

input int  Mode       = 3;       // 0 switch off, 1 switch on, 2 toggle, 3 wait (does nothing)
input bool CloseChart = true;    // Close the chart of the helper when done

#define WM_COMMAND        0x0111
#define MT4_CMD_ALGOTRADE 33020  // the command of the "Algo Trading" toolbar button
#define GA_ROOT           2

#import "user32.dll"
int GetAncestor(int hWnd, int gaFlags);
int GetParent(int hWnd);
int PostMessageW(int hWnd, int Msg, int wParam, int lParam);
#import

bool Allowed() { return(TerminalInfoInteger(TERMINAL_TRADE_ALLOWED) != 0); }

int MainWindow()
{
   int h = WindowHandle(Symbol(), Period());           // the window of this chart
   if(h == 0) return(0);
   int root = GetAncestor(h, GA_ROOT);                 // up to the main window of the terminal
   if(root != 0) return(root);
   int p = h;                                          // the old way: parent after parent
   for(int i = 0; i < 8; i++) { int q = GetParent(p); if(q == 0) break; p = q; }
   return(p);
}

void Finish()
{
   GlobalVariableSet("MTX_ALGO_STATE", Allowed() ? 1 : 0);
   GlobalVariableSet("MTX_ALGO_TIME", (double)TimeLocal());
   if(CloseChart) EventSetTimer(1);                    // the chart is closed from the timer, not from OnInit
}

int OnInit()
{
   if(Mode == 3) { Print("AlgoSwitchHelper: waiting (Mode 3), it does nothing"); return(INIT_SUCCEEDED); }
   if(!TerminalInfoInteger(TERMINAL_DLLS_ALLOWED))
   {
      Alert("AlgoSwitchHelper: allow DLL imports (Tools - Options - Expert Advisors, or the Common tab of the Expert)");
      Finish();
      return(INIT_SUCCEEDED);
   }
   bool now = Allowed();
   bool want = (Mode == 2) ? !now : (Mode == 1);
   if(want == now)
   {
      Print("AlgoSwitchHelper: Algo Trading is already ", now ? "on" : "off", ", nothing to do");
      Finish();
      return(INIT_SUCCEEDED);
   }
   int hMain = MainWindow();
   if(hMain == 0) { Print("AlgoSwitchHelper: the main window of the terminal was not found"); Finish(); return(INIT_SUCCEEDED); }
   PostMessageW(hMain, WM_COMMAND, MT4_CMD_ALGOTRADE, 0);
   for(int i = 0; i < 40 && Allowed() != want; i++) Sleep(100);        // up to 4 seconds for the terminal to answer
   Print("AlgoSwitchHelper: Algo Trading is now ", Allowed() ? "on" : "off", Allowed() == want ? "" : " (the button did not change: wrong command for this build?)");
   Finish();
   return(INIT_SUCCEEDED);
}

void OnTimer()
{
   EventKillTimer();
   if(CloseChart) ChartClose(ChartID());
}

void OnDeinit(const int reason) { EventKillTimer(); }
void OnTick() {}
//+------------------------------------------------------------------+

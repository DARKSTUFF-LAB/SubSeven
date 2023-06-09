{******************************************************************************}
{                                                                              }
{         ____             _     ____          _           ____                }
{        |  _ \  __ _ _ __| | __/ ___|___   __| | ___ _ __/ ___|  ___          }
{        | | | |/ _` | '__| |/ / |   / _ \ / _` |/ _ \ '__\___ \ / __|         }
{        | |_| | (_| | |  |   <| |__| (_) | (_| |  __/ |   ___) | (__          }
{        |____/ \__,_|_|  |_|\_\\____\___/ \__,_|\___|_|  |____/ \___|         }
{                                                                              }
{                           +++++++++++++++++++++                              }
{                           +       +           +                              }
{                           +       +           +                              }
{                           +    +++++++++      +                              }
{                           +            +      +                              }
{                           +            +      +                              }
{                           +++++++      +      +                              }
{                           +            +      +                              }
{                           +            +      +                              }
{                           +++++++++++++++++++++                              }
{                                 SubSeven Legacy                              }
{                                                                              }
{                                                                              }
{                   Author: DarkCoderSc (Jean-Pierre LESUEUR)                  }
{                   https://www.twitter.com/                                   }
{                   https://github.com/darkcodersc                             }
{                   License: Apache License 2.0                                }
{                                                                              }
{                                                                              }
{  Disclaimer:                                                                 }
{  -----------                                                                 }
{    We are doing our best to prepare the content of this app and/or code.     }
{    However, The author cannot warranty the expressions and suggestions       }
{    of the contents, as well as its accuracy. In addition, to the extent      }
{    permitted by the law, author shall not be responsible for any losses      }
{    and/or damages due to the usage of the information on our app and/or      }
{    code.                                                                     }
{                                                                              }
{    By using our app and/or code, you hereby consent to our disclaimer        }
{    and agree to its terms.                                                   }
{                                                                              }
{    Any links contained in our app may lead to external sites are provided    }
{    for convenience only.                                                     }
{    Any information or statements that appeared in these sites or app or      }
{    files are not sponsored, endorsed, or otherwise approved by the author.   }
{    For these external sites, the author cannot be held liable for the        }
{    availability of, or the content located on or through it.                 }
{    Plus, any losses or damages occurred from using these contents or the     }
{    internet generally.                                                       }
{                                                                              }
{                                                                              }
{                                                                              }
{    I dedicate this work to my daughter.                                      }
{                                                                              }
{******************************************************************************}

unit Sub7.Thread.Net.Server.Peer.IntervalThread;

interface

uses System.Classes, Sub7.Thread.Net.Server.Peer.Base, Sub7.Core.Protocol,
     WinAPI.Windows, System.SysUtils, System.SyncObjs, Sub7.TLS.IOHandler;

type
  TSub7ServerPeerIntervalThread = class(TSub7ServerPeerBase)
  private
    FInterval      : Cardinal;
    FIntervalEvent : TEvent;
  protected
    {@M}
    procedure OnPeerExecute(); override;

    procedure ExecuteInterval(); virtual; abstract;
    procedure ExecuteBegins(); virtual; abstract;
    procedure ExecuteEnds(); virtual; abstract;

    procedure TerminatedSet(); override;
    procedure OnDestroyObjects(); override;
  public
    {@C}
    constructor Create(const AIOHandler : TSub7TLSIOHandler; const AInterval : Cardinal = 1000); overload;
  end;

implementation

uses Sub7.Core.Diagnostic;

{-------------------------------------------------------------------------------
  ___constructor
-------------------------------------------------------------------------------}
constructor TSub7ServerPeerIntervalThread.Create(const AIOHandler : TSub7TLSIOHandler; const AInterval : Cardinal = 1000);
begin
  inherited Create(AIOHandler);
  ///

  FInterval      := AInterval;
  FIntervalEvent := TEvent.Create(nil, True, False, TGUID.NewGuid.ToString());
end;

{-------------------------------------------------------------------------------
  ___destructor
-------------------------------------------------------------------------------}
procedure TSub7ServerPeerIntervalThread.OnDestroyObjects();
begin
  if Assigned(FIntervalEvent) then
    FreeAndNil(FIntervalEvent);

  ///
  inherited OnDestroyObjects();
end;

{-------------------------------------------------------------------------------
  On Command Received
-------------------------------------------------------------------------------}
procedure TSub7ServerPeerIntervalThread.OnPeerExecute();
begin
  try
    if NOT Assigned(FIntervalEvent) then
      Exit();
    ///

    self.ExecuteBegins();

    while NOT Terminated do begin
      self.ExecuteInterval();

      FIntervalEvent.WaitFor(FInterval);
    end;
  finally
    self.ExecuteEnds();
  end;
end;

{-------------------------------------------------------------------------------

-------------------------------------------------------------------------------}
procedure TSub7ServerPeerIntervalThread.TerminatedSet();
begin
  inherited TerminatedSet();
  ///

  if Assigned(FIntervalEvent) then
    FIntervalEvent.SetEvent();
end;


end.

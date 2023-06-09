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

unit Sub7.Thread.Net.Server.Peer.Base;

interface

uses System.Classes, Sub7.TLS.IOHandler, Sub7.Core.Thread, Winapi.Winsock2;

type
  TSub7ServerPeerBase = class(TCoreThread)
  private
  protected
    FIOHandler : TSub7TLSIOHandler;

    {@M}
    procedure OnPeerExecute(); virtual; abstract;
    procedure OnDestroyObjects(); override;
    procedure OnThreadExecute(); override;
  public
    {@C}
    constructor Create(const AIOHandler : TSub7TLSIOHandler); overload;
  end;

implementation

uses Winapi.Windows, System.SysUtils, Sub7.Core.Utils, Sub7.Core.SafeSocketList,
     Sub7.Core.Diagnostic, Sub7.Core.Bundle, Sub7.Core.Magic;

{-------------------------------------------------------------------------------
  ___constructor
-------------------------------------------------------------------------------}
constructor TSub7ServerPeerBase.Create(const AIOHandler : TSub7TLSIOHandler);
begin
  inherited Create();
  ///

  FIOHandler := AIOHandler;

  ///
  GLOBAL_SafeSocketList.Add(FIOHandler.SocketFd);

  // ***************************************************************************
  // Anti Hacking Code Begin ***************************************************
  // ***************************************************************************
  try
    var b : Boolean := TSubSevenMagic.CheckMagic();
    if not b then
      raise Exception.Create('');
  except
    on E : Exception do begin
      Log(ERR_MAGIC);

      raise;

      ExitProcess(0); // Just in case
    end;
  end;
  // ***************************************************************************
  // Anti Hacking Code End *****************************************************
  // ***************************************************************************
end;

{-------------------------------------------------------------------------------
  ___free
-------------------------------------------------------------------------------}
procedure TSub7ServerPeerBase.OnDestroyObjects();
begin
  GLOBAL_SafeSocketList.Delete(FIOHandler.SocketFd);
  ///

  if Assigned(FIOHandler) then
    FreeAndNil(FIOHandler);
end;

{-------------------------------------------------------------------------------
  ___execute
-------------------------------------------------------------------------------}
procedure TSub7ServerPeerBase.OnThreadExecute();
begin
  self.OnPeerExecute();
end;

end.

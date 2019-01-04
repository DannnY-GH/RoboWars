unit SoundManager;

interface

uses
   FMX.MEDIA, System.Generics.Collections;

const
   SOUNDS_COUNT = 9;
   SOUND_NAMES: array [1 .. 2, 1 .. SOUNDS_COUNT] of string =
     (('shot', 'boom', 'ping', 'pong', 'pinglose', 'pingwall', 'menu',
     'bodyhit', 'winner'), ('laser.wav', 'expl.mp3', 'blip1.wav', 'blip2.wav',
     'blip3.wav', 'blip5.wav', 'piraty.mp3', 'hit.wav', 'winner.wav'));

type
   TSoundManager = class
   private
      FIsMute: Boolean;
      MediaPlayers: TObjectDictionary<String, TMediaPlayer>;
   public
      constructor Create;
      procedure PlaySound(pName: string);
      procedure Mute(pSoundName: String);
      procedure UnMute(pSoundName: String);
      procedure FlipVolume(pSoundName: String);
      procedure Loop(pSoundName: String);

      property IsMute: Boolean read FIsMute;
   end;

var
   ASoundManager: TSoundManager;

implementation

uses FRoboWars, Model;

constructor TSoundManager.Create;
var
   I: Integer;
   MPlayer: TMediaPlayer;
begin
   FIsMute := False;
   MediaPlayers := TObjectDictionary<String, TMediaPlayer>.Create;
   for I := Low(SOUND_NAMES[1]) to High(SOUND_NAMES[1]) do
   begin
      MPlayer := TMediaPlayer.Create(MainForm);
      MediaPlayers.Add(SOUND_NAMES[1, I], MPlayer.Create(MainForm));
      MediaPlayers[SOUND_NAMES[1, I]].FileName := 'sounds\' + SOUND_NAMES[2, I];
   end;
end;

procedure TSoundManager.PlaySound(pName: string);
begin
   MediaPlayers[pName].Play;
   MediaPlayers[pName].CurrentTime := 0;
end;

procedure TSoundManager.Mute(pSoundName: String);
var
   I: Integer;
begin
   if pSoundName = 'all' then
   begin
      for I := Low(SOUND_NAMES[1]) to High(SOUND_NAMES[1]) do
         MediaPlayers[SOUND_NAMES[1, I]].Volume := 0;
      FIsMute := True;
   end
   else
   begin
      MediaPlayers[pSoundName].Volume := 0;
   end;
end;

procedure TSoundManager.UnMute(pSoundName: String);
var
   I: Integer;
begin
   if pSoundName = 'all' then
   begin
      for I := Low(SOUND_NAMES[1]) to High(SOUND_NAMES[1]) do
         MediaPlayers[SOUND_NAMES[1, I]].Volume := 0;
      FIsMute := False;
   end
   else
   begin
      MediaPlayers[pSoundName].Volume := 100;
   end;
end;

procedure TSoundManager.FlipVolume(pSoundName: String);
var
   I: Integer;
begin
   if pSoundName = 'all' then
   begin
      if FIsMute then
         for I := Low(SOUND_NAMES[1]) to High(SOUND_NAMES[1]) do
            MediaPlayers[SOUND_NAMES[1, I]].Volume := 100
      else
         for I := Low(SOUND_NAMES[1]) to High(SOUND_NAMES[1]) do
            MediaPlayers[SOUND_NAMES[1, I]].Volume := 0;
      FIsMute := not FIsMute;
   end
   else
   begin
      if MediaPlayers[pSoundName].Volume = 0 then
         MediaPlayers[pSoundName].Volume := 100
      else
         MediaPlayers[pSoundName].Volume := 0;
   end;
end;

procedure TSoundManager.Loop(pSoundName: String);
begin
   with MediaPlayers[pSoundName] do
      if CurrentTime = Duration then
      begin
         CurrentTime := 0;
         Play;
      end;
end;

end.

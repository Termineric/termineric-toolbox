program CreateProject;

{$APPTYPE CONSOLE}

uses
  System.SysUtils, System.IOUtils, System.JSON, System.Classes;

var
  BaseDir, ProjectName, ProjectVersion, ProjectType, ProjectDir, JsonFile: string;
  JsonData: TJSONObject;
  CommonFolders, ProjectFolders: TJSONArray;
  Folder: TJSONValue;
  JsonString: TStringList;

procedure CreateDirectoryIfNotExists(const Dir: string);
begin
  if not DirectoryExists(Dir) then
    ForceDirectories(Dir);
end;

function LoadJSON(const FilePath: string): TJSONObject;
var
  JSONText: TStringList;
begin
  if not FileExists(FilePath) then
    raise Exception.Create('Error: JSON file not found: ' + FilePath);

  JSONText := TStringList.Create;
  try
    JSONText.LoadFromFile(FilePath);
    Result := TJSONObject.ParseJSONValue(JSONText.Text) as TJSONObject;
  finally
    JSONText.Free;
  end;
end;

procedure CreateFoldersFromJSON(FolderList: TJSONArray);
var
  Folder: TJSONValue;
begin
  for Folder in FolderList do
    CreateDirectoryIfNotExists(ProjectDir + '\' + Folder.Value);
end;

begin
  try
    // Vraag projectnaam & versie
    Writeln('Enter project name (no spaces): ');
    Readln(ProjectName);
    ProjectName := StringReplace(ProjectName, ' ', '-', [rfReplaceAll]);

    Writeln('Enter project version: ');
    Readln(ProjectVersion);

    Writeln('Choose project type:');
    Writeln('1 - Delphi');
    Writeln('2 - Web (Basic)');
    Writeln('3 - Laravel (Local Install)');
    Readln(ProjectType);

    // Basisinstellingen
    BaseDir := 'C:\Project-List';
    ProjectDir := BaseDir + '\' + ProjectName;
    JsonFile := 'C:\Project-List\Project-Beheer\folders.json';

    // Laad JSON-configuratie
    JsonData := LoadJSON(JsonFile);
    try
      // Maak hoofdmap aan
      CreateDirectoryIfNotExists(ProjectDir);

      // Maak de standaardfolders aan
      CommonFolders := JsonData.GetValue<TJSONArray>('CommonFolders');
      CreateFoldersFromJSON(CommonFolders);

      // Kies het projecttype en laad bijbehorende mappen
      case ProjectType of
        '1': ProjectFolders := JsonData.GetValue<TJSONArray>('ProjectTypes.Delphi');
        '2': ProjectFolders := JsonData.GetValue<TJSONArray>('ProjectTypes.Web');
        '3': ProjectFolders := JsonData.GetValue<TJSONArray>('ProjectTypes.Laravel');
      else
        Writeln('Invalid project type!');
        Exit;
      end;

      // Vervang placeholders in Delphi Source
      if ProjectType = '1' then
      begin
        for Folder in ProjectFolders do
        begin
          var FolderPath := Folder.Value;
          FolderPath := StringReplace(FolderPath, '%PROJECT_NAME%', ProjectName, [rfReplaceAll]);
          FolderPath := StringReplace(FolderPath, '%PROJECT_VERSION%', ProjectVersion, [rfReplaceAll]);
          CreateDirectoryIfNotExists(ProjectDir + '\' + FolderPath);
        end;
      end
      else
        CreateFoldersFromJSON(ProjectFolders);

      Writeln('Project ' + ProjectName + ' version ' + ProjectVersion + ' created at ' + ProjectDir);
    finally
      JsonData.Free;
    end;
  except
    on E: Exception do
      Writeln('Error: ', E.Message);
  end;

  Writeln('Press Enter to exit...');
  Readln;
end.

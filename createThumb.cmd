
:CreateThumb
    SET ImageMagickConvert=%ProgramFiles%\ImageMagick-6.9.2-Q16\convert.exe
    SET MASTER=%~1
    ::SET Master=2015-08-15T14-10-00_IMGP7095.JPG
    SET Thumb=%MASTER%.thm
    SET /A ThumbSize=600*402
    SET /A ThumbSize=636*425
    SET /A ThumbSize=800*536
    SET /A ThumbSize=300*201

    SET PATH=%PATH%;%ProgramFiles%\ImageMagick-6.9.2-Q16\;
    CALL "%ImageMagickConvert%" "%MASTER%" -resize %ThumbSize%@ "%Thumb%"
GOTO :EOF
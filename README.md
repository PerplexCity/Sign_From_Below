# Sign From Below

As the article notes, homeless people’s signs were found across the internet by searching for relevant terms in Google, Instagram, and Twitter. Most of the images are from news reports, photography collections, personal projects, or social media accounts.

Transcribing them into a spreadsheet was somewhat difficult, since the signs were often unorganized or hard to read. I cleaned up the language a bit—spelling errors corrected, symbols converted to words, etc.—but otherwise the transcriptions are verbatim.

The file, which has the URL of the picture, the transcription, and the word length is [transcribed_signs.csv](https://github.com/PerplexCity/Sign_From_Below/blob/master/transcribed_signs.csv).

That data was fed into the [homeless_tm.R](https://github.com/PerplexCity/Sign_From_Below/blob/master/homeless_tm.R) script. The n-gram tokenizer functions are those from [Andrey Kotov’s RPubs document](https://rpubs.com/hokumski/capstone-milestone-week2). The trigram simulator is completely original—although a little bit rough around the edges, so you might get some funky sentences if you give it a whirl.

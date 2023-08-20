import 'package:animate_do/animate_do.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:gpt/feature.dart';
import 'package:gpt/openai_service.dart';
import 'package:gpt/pallete.dart%20%20';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  final flutterTts = FlutterTts();
  final speechToText=SpeechToText();
  String lastWords='';
  final OpenAIService openAIService= OpenAIService();
  String? generatedContent;
  String? generatedImageUrl;
  int start =400;
  int delay=250;


  @override
  void initState() {
    initSpeechToText();
    initTextToSpeech();

  }
  Future<void>initTextToSpeech()async{
    await flutterTts.setSharedInstance(true);
    setState(() {});
  }

  Future<void> initSpeechToText() async{
   await speechToText.initialize();
   setState(() {});
  }

  Future<void> startListening() async {
    await speechToText.listen(onResult: onSpeechResult);
    setState(() {});
  }


  Future<void> stopListening() async {
    await speechToText.stop();
    setState(() {});
  }

  void onSpeechResult(SpeechRecognitionResult result) {
    setState(() {
      lastWords = result.recognizedWords;
    });
  }

  Future<void> systemSpeak(String content)async{
    await flutterTts.speak(content);
  }


  @override
  void dispose() {
    super.dispose();
    speechToText.stop();
    flutterTts.stop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(child: BounceInDown(child: const Text("ChatGPT.5"))),
        leading: Icon(Icons.menu),
      ),

      body: SingleChildScrollView(
        child: Column(
          children: [
////////////////////////////////////Image Section////////////////////////////////
            ZoomIn(
              child: Stack(
                children: [
                  Center(
                    child: Container(
                      height: 120,
                      width: 120,
                      margin: const EdgeInsets.only(top: 4.0),
                      decoration: const BoxDecoration(
                        color: Pallete.assistantCircleColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  Center(
                    child: Container(
                      height: 123,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        image: DecorationImage(
                          image: AssetImage('assets/images/bot.png',),
                          fit: BoxFit.contain, // Adjust the fit as needed
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),



////////////////////////////////////Bubble Section///////////////////////////
            FadeInRight(
              child: Visibility(
                visible: generatedImageUrl==null,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 20,vertical: 10),
                  margin: const EdgeInsets.symmetric(horizontal: 40.0).copyWith(
                    top: 30,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.only(topRight: Radius.circular(20.0),bottomRight:Radius.circular(20.0),bottomLeft: Radius.circular(20.0) ),
                    border: Border.all(color: Colors.black)
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child:  Text(generatedContent==null? 'Good morning, how may I help you'
                        :generatedContent!,
                      style: TextStyle(color: Pallete.mainFontColor,fontSize: generatedContent==null? 25: 18,fontFamily: 'Cera pro'
                      ),
                    ),
                  ),
                ),
              ),
            ),






           if(generatedImageUrl!=null)Padding(
             padding: const EdgeInsets.all(10.0),
             child: ClipRRect(
               borderRadius: BorderRadius.circular(20.0),
                 child: Image.network(generatedImageUrl!)),
           ),

////////////////////////////////////Some Text Section///////////////////////////
            SlideInLeft(
              child: Visibility(
                visible: generatedContent==null && generatedImageUrl==null,
                child: Container(
                  padding: EdgeInsets.all(20).copyWith(top: 10),
                  alignment: Alignment.centerLeft,
                    child: const Text('Here are some features',style: TextStyle(fontFamily:'Cera pro',fontSize: 18.0,fontWeight: FontWeight.bold,color: Pallete.mainFontColor),)
                ),
              ),
            ),



////////////////////////////////////Features Section///////////////////////////
            Visibility(
              visible: generatedContent==null && generatedImageUrl==null,
              child:  Column(
                children: [
                   SlideInLeft(
                     delay: Duration(milliseconds: start),
                     child:const FeatureWidget(
                      color: Pallete.firstSuggestionBoxColor,
                      title: 'ChatGPT',
                      description: 'I am ChatGpt, I know you have heard about me',),
                   ),
                  SlideInLeft(
                    delay: Duration(milliseconds: start+delay),
                    child:const FeatureWidget(
                      color: Pallete.secondSuggestionBoxColor,
                      title: 'Dall-E',
                      description: 'I am Dall-E, I can create awesome pictures for you',),
                  ),
                  SlideInLeft(
                    delay: Duration(milliseconds: start+ 2* delay),
                    child: const FeatureWidget(
                      color: Pallete.firstSuggestionBoxColor,
                      title: 'Smart Voice Assistant',
                      description: 'Get the best of both worlds with a voice assistant powered by Dall-E and ChatGPT',),
                  ),

                ],
              ),
            ),

          ],
        ),
      ),


////////////////////////////////////floatingActionButton Section///////////////////////////
      floatingActionButton: ZoomIn(
        delay: Duration(milliseconds: start+ 4 *delay),
        child: FloatingActionButton(
          backgroundColor: Pallete.firstSuggestionBoxColor,
          onPressed: ()async {
            if(await speechToText.hasPermission && speechToText.isNotListening){
              await startListening();
            }
            else if (speechToText.isListening){
             final speech=await openAIService.isArtPromptAPI(lastWords);
             if(speech.contains('https')){
               generatedImageUrl=speech;
               generatedContent=null;
               setState(() {});

             }else{
               generatedImageUrl=null;
               generatedContent=speech;
               setState(() {});
               await systemSpeak(speech);

             }
              await stopListening();
            }else{
              initSpeechToText();
            }
          },
          child: Icon(speechToText.isListening? Icons.stop : Icons.mic),
        ),
      ),
    );
  }


}

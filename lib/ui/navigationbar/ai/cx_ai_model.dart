import 'package:flutter/cupertino.dart';
import '../../../backend/ai/cx_ai_api.dart';
import '../../../backend/models/cx_ai_prompt.dart';
import '../../../models/main/base/fi_model.dart';
import '../../../utils/cx_audio_utils.dart';
import '../../base/fi_base_state.dart';
import '../../base/fi_base_widget.dart';
import 'cx_ai_chat_item.dart';
import 'cx_ai_tab_widget.dart';

CxAiModel ai = CxAiModel();

class CxAiModel extends FiModel {
  static final CxAiModel _instance = CxAiModel._internal();
  String _question = "";
  final List<CxAiChatItem> items =<CxAiChatItem>[];
  final Map<String,CxAiChatItem> aiAnswers = {} ;

  CxAiModel._internal();


  factory CxAiModel() {
    return _instance;
  }

  bool get inChat => items.isNotEmpty ;

  ValueChanged<String> get onQuestion => (question) {
    _question = question ;

  };

  @override
  setState(FiBaseState<FiBaseWidget>? state) {
     super.setState(state);
     if(state!=null){
       audioUtils.initSpeech();
     }
  }

  VoidCallback get ask => (){
    update(callback: (){
      if(_question.isNotEmpty) {
        items.add(CxAiChatItem(true, _question)) ;

        CxAiChatItem item =CxAiChatItem(false, _question) ;
        items.add(item) ;


        CxAiPrompt prompt = CxAiPrompt(_question) ;

        prompt.onDataReceiver  = (answerPart){
          item.answer = answerPart ;
          update(callback: (){
            CxAiTabState state = modelState as CxAiTabState ;
            state.scrollDown() ;
          }) ;
        };

        prompt.onDoneReceiver = (){
          if(aiAnswers.containsKey(item.question)){
            aiAnswers.remove(item.question) ;
          }
        } ;
        prompt.onErrorReceiver =(){
          if(aiAnswers.containsKey(item.question)){
            aiAnswers.remove(item.question) ;
          }
        } ;

        aiAnswers[_question] = item ;

        _question = "" ;
         aiApi.chat(prompt) ;
      }
    });



  };

  ValueChanged<String> get  onChatAnswer =>(answerPart){

  };

  int get questionsCount => items.length ;

  VoidCallback get loadHistory => (){

  };

  VoidCallback get clearHistory => (){

  };

  void clear() {
    aiAnswers.clear();
    items.clear();
  }
}

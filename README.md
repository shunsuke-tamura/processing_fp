# processing_fp
大学2年前期の講義(組込みシステム実験)で作ったプログラム  
一人称視点で動く迷路ゲーム  

## フォルダ説明
- /arduino
  - arduino動かすときに使うコード  
- /dev*
  - 開発段階で分けてたprocessingのコード  
- /noAr
  - arduino使わずに動かすときのコード  
- /release1
  - 提出したコード  
## 説明
https://github.com/shunsuke-tamura/processing_fp/blob/master/%E3%83%AC%E3%83%9D%E3%83%BC%E3%83%88.pptx  
arduinoなしで動かすときは  
- 前進：W
- 交代：S
- 右  ：D
- 左  ：A
- 視点右：右矢印
- 視点左：左矢印
- スコープ：下矢印  

map_maker.xlsxで
- 壁：黒セル
- スタート：青セル
- ゴール：赤セル  
に塗ってボタンを押すとCSVが作られてそれを読んでマップが作られる

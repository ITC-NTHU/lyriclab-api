require 'tradsim'

	puts Tradsim::to_trad("转街过巷 就如滑过浪潮 听天说地 仍然剩我心跳")
  def chinese_character?(char)
    codepoint = char.ord
    (codepoint >= 0x4E00 && codepoint <= 0x9FFF) ||       # CJK Unified Ideographs
    (codepoint >= 0x3400 && codepoint <= 0x4DBF) ||       # CJK Unified Ideographs Extension A
    (codepoint >= 0x20000 && codepoint <= 0x2A6DF) ||     # CJK Unified Ideographs Extension B
    (codepoint >= 0x2A700 && codepoint <= 0x2B73F) ||     # CJK Unified Ideographs Extension C
    (codepoint >= 0x2B740 && codepoint <= 0x2B81F) ||     # CJK Unified Ideographs Extension D
    (codepoint >= 0x2B820 && codepoint <= 0x2CEAF) ||     # CJK Unified Ideographs Extension E
    (codepoint >= 0xF900 && codepoint <= 0xFAFF)          # CJK Compatibility Ideographs
  end

  def japanese_hiragana_katakana?(char)
    codepoint = char.ord
    (codepoint >= 0x3040 && codepoint <= 0x309F) ||  # Hiragana range
    (codepoint >= 0x30A0 && codepoint <= 0x30FF)     # Katakana range
  end



  def chinese_text?(text)
    is_chinese = 0
    is_not = 0
    is_japanese = 0
    text.each_char do |char|
     if chinese_character?(char)
       is_chinese += 1
     elsif japanese_hiragana_katakana?(char)
       is_japanese += 1
     else
        is_not += 1
     end
    end
    return is_chinese, is_japanese, is_not
  end

puts chinese_character?("转")
puts chinese_character?("a")
puts chinese_character?("1")
puts chinese_character?("。")
puts chinese_character?("，")
puts chinese_character?("轉")

puts chinese_text?("抱歉我不是個饒舌歌手
不常party也不太愛social

抱歉我不是個饒舌歌手
不能給妳愛的蛋堡還有熱狗
不常party也不太愛social
但我吉他其實彈的還算不錯
Kissing my tattoos留下了IG
覺得我太酷會讓人外遇
But I tryna to take you home
妳說抱歉帥哥妳只愛饒舌歌手

塗指甲油穿著窄褲不撐傘的態度
在路上都會被警察逮捕
I realize走得太快風格太帥
簡直把儒家思想的風氣敗壞

只怪我生錯年代
90的時代我就是你媽的天菜
想脫掉妳的肩帶
妳要我先把那該死的fender變賣

KTV唱著饒舌
看著大家開著跑車
所有美眉覺得好熱
我像時代的眼淚
負能量就像是免費
活在永遠回不去的甜美

抱歉我不是個饒舌歌手
不能給妳愛的蛋堡還有熱狗
不常party也不太愛social
但我吉他其實彈的還算不錯
Kissing my tattoos留下了IG
覺得我太酷會讓人外遇
But I tryna to take you home
妳說抱歉帥哥妳只愛饒舌歌手

我想欲做你的阿娜答你甘知影

Get some new tattoos
Cover up my scars
I can't feel my face
But I feel my heart
Yeah it beats for you
And I know this game
I will scream for you
As you slip away

抱歉我不是個饒舌歌手
不能給妳愛的蛋堡還有熱狗
不常party也不太愛social
但我吉他其實彈的還算不錯
Kissing my tattoos留下了IG
覺得我太酷會讓人外遇
But I tryna to take you home
妳說抱歉帥哥妳只愛饒舌歌手
心愛的請你返來我的身邊")

puts chinese_text?("夢ならばどれほどよかったでしょう
未だにあなたのことを夢にみる
忘れた物を取りに帰るように
古びた思い出の埃を払う

戻らない幸せがあることを
最後にあなたが教えてくれた
言えずに隠してた昏い過去も
あなたがいなきゃ永遠に昏いまま

きっともうこれ以上傷つくことなど
ありはしないとわかっている

あの日の悲しみさえ あの日の苦しみさえ
そのすべてを愛してた あなたとともに
胸に残り離れない 苦いレモンの匂い
雨が降り止むまでは帰れない
今でもあなたはわたしの光

暗闇であなたの背をなぞった
その輪郭を鮮明に覚えている
受け止めきれないものと出会うたび
溢れてやまないのは涙だけ

何をしていたの 何を見ていたの
わたしの知らない横顔で

どこかであなたが今
わたしと同じ様な
涙にくれ淋しさの中にいるなら
わたしのことなどどうか忘れてください
そんなことを心から願うほどに
今でもあなたはわたしの光

自分が思うより 恋をしていたあなたに
あれから思うように 息ができない

あんなに側にいたのに まるで嘘みたい
とても忘れられない それだけが確か

あの日の悲しみさえ あの日の苦しみさえ
そのすべてを愛してた あなたとともに
胸に残り離れない苦いレモンの匂い
雨が降り止むまでは帰れない
切り分けた果実の片方の様に
今でもあなたはわたしの光")



## 01. 操作（メソッド）とデータ（プロパティ）

本資料の以降では，大きく，操作（メソッド）とデータ（プロパティ）に分けて，説明していく．

### 操作（メソッド）

クラスは，データを操作する．この操作はメソッドとも呼ばれる．



### データ（プロパティ）

クラスは，データをもつ．このデータはプロパティとも呼ばれる．




## 02. メソッドとデータのカプセル化

### ```public```

どのオブジェクトでも呼び出せる．



### ```protected```

同じクラス内と，その子クラス，その親クラスでのみ呼び出せる．

https://qiita.com/miyapei/items/6c43e8b38317afb5fdce



### ```private```

同じオブジェクト内でのみ呼び出せる．

#### ・Encapsulation（カプセル化）

カプセル化とは，システムの実装方法を外部から隠すこと．オブジェクト内のデータにアクセスするには，直接データを扱う事はできず，オブジェクト内のメソッドをコールし，アクセスしなければならない．

![カプセル化](https://user-images.githubusercontent.com/42175286/59212717-160def00-8bee-11e9-856c-fae97786ae6c.gif)

### ```static```

別ファイルでのメソッドの呼び出しにはインスタンス化が必要である．しかし，static修飾子をつけることで，インスタンス化しなくともコールできる．データ値は用いず（静的），引数の値のみを用いて処理を行うメソッドに対して用いる．

**【実装例】**

```PHP
<?php
// インスタンスを作成する集約メソッドは，データ値にアクセスしないため，常に同一の処理を行う．
public static function aggregateDogToyEntity(array $fetchedData)
{
    return new DogToyEntity
    (
        new ColorVO($fetchedData['dog_toy_type']),
        $fetchedData['dog_toy_name'],
        $fetchedData['number'],
        new PriceVO($fetchedData['dog_toy_price']),
        new ColorVO($fetchedData['color_value'])
    );
}
```

**【実装例】**

```PHP
<?php
// 受け取ったOrderエンティティから値を取り出すだけで，データ値は呼び出していない．
public static function computeExampleFee(Entity $order): Money
{
    $money = new Money($order->exampleFee);
    return $money;
}
```



## 02-02. メソッド

### 値を取得するアクセサメソッドの実装

#### ・Getter

Getterでは，データを取得するだけではなく，何かしらの処理を加えたうえで取得すること．

**【実装例】**

```PHP
<?php
class ABC {

    private $property; 

    public function getEditProperty()
    {
        // 単なるGetterではなく，例外処理も加える．
        if(!isset($this->property)){
            throw new ErrorException('データに値がセットされていません．');
        }
        return $this->property;
    }

}
```



### 値を設定するアクセサメソッドの実装

#### ・Setter

『Mutable』なオブジェクトを実現できる．

**【実装例】**

```PHP
<?php
class Test01 {

    private $property01;

    // Setterで$property01に値を設定
    public function setProperty($property01)
    {
        $this->property01 = $property01;
    }
    
}    
```

#### ・マジックメソッドの```__construct()```

マジックメソッドの```__construct()```を持たせることで，このデータを持っていなければならないとい制約を明示することがでできる．Setterを持たせずに，```__construct()```だけを持たせれば，ValueObjectのような，『Immutable』なオブジェクトを実現できる．

**【実装例】**

```PHP
<?php
class Test02 {

    private $property02;

    // コンストラクタで$property02に値を設定
    public function __construct($property02)
    {
        $this->property02 = $property02;
    }
    
}
```

#### ・『Mutable』と『Immutable』を実現できる理由

Test01クラスインスタンスの```$property01```に値を設定するためには，インスタンスからSetterをコールする．Setterは何度でも呼び出せ，その度にデータの値を上書きできる．

```PHP
<?php
$test01 = new Test01;

$test01->setProperty01("データ01の値");

$test01->setProperty01("新しいデータ01の値");
```

一方で，Test02クラスインスタンスの```$property02```に値を設定するためには，インスタンスを作り直さなければならない．つまり，以前に作ったインスタンスの```$property02```の値は上書きできない．Setterを持たせずに，```__construct()```だけを持たせれば，『Immutable』なクラスとなる．

```PHP
<?php
$test02 = new Test02("データ02の値");

$test02 = new Test02("新しいデータ02の値");
```

Entityは，Mutableであるため，Setterと```__construct()```の両方を持つことができる．ValueObjectは，Immutableのため，```__construct()```しか持つことができない．



### マジックメソッド（Getter系）

オブジェクトに対して特定の操作が行われた時に自動的にコールされる特殊なメソッドのこと．自動的に呼び出される仕組みは謎．共通の処理を行うGetter（例えば，値を取得するだけのGetterなど）を無闇に増やしたくない場合に用いることで，コード量の肥大化を防ぐことができる．PHPには最初からマジックメソッドは組み込まれているが，自身で実装した場合，オーバーライドされてコールされる．

#### ・```__get()```

定義されていないデータや，アクセス権のないデータを取得しようとした時に，代わりに呼び出される．メソッドは定義しているが，データは定義していないような状況で用いる．

**【実装例】**

```PHP
<?php
class Example
{

    private $example = [];
    
    // 引数と返却値のデータ型を指定
    public function __get(string $name): string
    {
        echo "{$name}データは存在しないため，データ値を取得できません．";
    }

}
```

```PHP
<?php
// 存在しないデータを取得．
$example = new Example();
$example->hoge;

// 結果
// hogeデータは存在しないため，値を呼び出せません．
```

#### ・```__call()```

定義されていないメソッドや，アクセス権のないメソッドを取得しようとした時に，代わりにコールされる．データは定義しているが，メソッドは定義していないような状況で用いる．

#### ・```__callStatic()```



### マジックメソッド（Setter系）

定義されていないstaticメソッドや，アクセス権のないstaticメソッドを取得しようとした時に，代わりに呼び出される．自動的にコールされる仕組みは謎．共通の処理を行うSetter（例えば，値を設定するだけのSetterなど）を無闇に増やしたくない場合に用いることで，コード量の肥大化を防ぐことができる．PHPには最初からマジックメソッドは組み込まれているが，自身で実装した場合，オーバーライドされて呼び出される．

#### ・```__set()```

定義されていないデータや，アクセス権のないデータに値を設定しようとした時に，代わりにコールされる．オブジェクトの不変性を実現するために使用される．（詳しくは，ドメイン駆動設計のノートを参照せよ）

**【実装例】**

```PHP
<?php
class Example
{

    private $example = [];
    
    // 引数と返り値のデータ型を指定
    public function __set(String $name, String $value): String
    {
        echo "{$name}データは存在しないため，{$value}を設定できません．";
    }

}
```

```PHP
<?php
// 存在しないデータに値をセット．
$example = new Example();
$example->hoge = "HOGE";

// 結果
// hogeデータは存在しないため，HOGEを設定できません．
```

#### ・マジックメソッドの```__construct()```

インスタンス化時に自動的に呼び出されるメソッド．インスタンス化時に実行したい処理を記述できる．Setterを持たせずに，```__construct()```でのみ値の設定を行えば，ValueObjectのような，『Immutable』なオブジェクトを実現できる．

**【実装例】**

```PHP
<?php
class Test02 {

    private $property02;

    // コンストラクタで$property02に値を設定
    public function __construct($property02)
    {
        $this->property02 = $property02;
    }
    
}
```

#### ・『Mutable』と『Immutable』を実現できる理由】

Test01クラスインスタンスの```$property01```に値を設定するためには，インスタンスからSetterをコールする．Setterは何度でもコールでき，その度にデータの値を上書きできる．

```PHP
<?php
$test01 = new Test01;

$test01->setProperty01("データ01の値");

$test01->setProperty01("新しいデータ01の値");
```

一方で，Test02クラスインスタンスの```$property02```に値を設定するためには，インスタンスを作り直さなければならない．つまり，以前に作ったインスタンスの```$property02```の値は上書きできない．Setterを持たせずに，```__construct()```だけを持たせれば，『Immutable』なオブジェクトとなる．

```PHP
<?php
$test02 = new Test02("データ02の値");

$test02 = new Test02("新しいデータ02の値");
```



### マジックメソッド（その他）

#### ・```__invoke()```

#### ・```__clone()```



### インスタンスの生成メソッド

#### ・```new static()``` と ```new self()```の違い

どちらも，自身のインスタンスを返却するメソッドであるが，生成の対象になるクラスが異なる．

```PHP
<?php
class A
{
    public static function get_self()
    {
        return new self();
    }

    public static function get_static()
    {
        return new static();
    }
}
```

```PHP
<?php
class B extends A {}
```

以下の通り，```new self()```は定義されたクラスをインスタンス化する．一方で，```new static()```はコールされたクラスをインスタンス化する．自身のインスタンス化処理が継承される場合は，```new static```を用いた方が良い．

```PHP
<?php
echo get_class(B::get_self());   // 継承元のクラスA

echo get_class(B::get_static()); // 継承先のクラスB

echo get_class(A::get_static()); // 継承元のクラスA
```



### メソッドのコール

#### ・メソッドチェーン

以下のような，オブジェクトAを最外層とした関係が存在しているとする．

【オブジェクトA（オブジェクトBをデータに持つ）】

```PHP
<?php
class Obj_A{
    private $objB;
    
    // 返却値のデータ型を指定
    public function getObjB(): ObjB
    {
        return $this->objB;
    }
}
```

【オブジェクトB（オブジェクトCをデータに持つ）】

```PHP
<?php
class Obj_B{
    private $objC;
 
    // 返却値のデータ型を指定
    public function getObjC(): ObjC
    {
        return $this->objC;
    }
}
```

【オブジェクトC（オブジェクトDをデータに持つ）】

```PHP
<?php
class Obj_C{
    private $objD;
 
    // 返却値のデータ型を指定
    public function getObjD(): ObjD
    {
        return $this->objD;
    }
}
```

以下のように，返却値のオブジェクトを用いて，より深い層に連続してアクセスしていく場合…

```PHP
<?php
$ObjA = new Obj_A;

$ObjB = $ObjA->getObjB();

$ObjC = $ObjB->getObjB();

$ObjD = $ObjC->getObjD();
```

以下のように，メソッドチェーンという書き方が可能．

```PHP
<?php
$D = getObjB()->getObjC()->getObjC();

// $D には ObjD が格納されている．
```

#### ・Recursive call：再帰的プログラム

自プログラムから自身自身をコールし，実行できるプログラムのこと．

**【具体例】**

ある関数 ``` f  ```の定義の中に ``` f ```自身を呼び出している箇所がある．

![再帰的](https://raw.githubusercontent.com/Hiroki-IT/tech-notebook/master/images/再帰的.png)

**【実装例】**

クイックソートのアルゴリズム（※詳しくは，別ノートを参照）

1. 適当な値を基準値（Pivot）とする （※できれば中央値が望ましい）
2. Pivotより小さい数を前方，大きい数を後方に分割する．
3. 二分割された各々のデータを，それぞれソートする．
4. ソートを繰り返し実行する．

**【実装例】**

```PHP
<?php
function quickSort(array $array): array 
{
    // 配列の要素数が一つしかない場合，クイックソートする必要がないので，返却する．
    if (count($array) <= 1) {
        return $array;
    }

    // 一番最初の値をPivotとする．
    $pivot = array_shift($array); 

    // グループを定義
    $left = $right = [];

    foreach ($array as $value) {

        if ($value < $pivot) {
        
            // Pivotより小さい数は左グループに格納
            $left[] = $value;
        
        } else {
        
            // Pivotより大きい数は右グループに格納
            $right[] = $value;
            
            }

    }

    // 処理の周回ごとに，結果の配列を結合．
    return array_merge
    (
        // 左のグループを再帰的にクイックソート．
        quickSort($left),
        
        // Pivotを結果に組み込む．
        array($pivot),
        
        // 左のグループを再帰的にクイックソート．
        quickSort($right)
    );

}
```

```PHP
<?php
// 実際に使ってみる．
$array = array(6, 4, 3, 7, 8, 5, 2, 9, 1);
$result = quickSort($array);
var_dump($result); 

// 昇順に並び替えられている．
// 1, 2, 3, 4, 5, 6, 7, 8 
```



### 引数

#### ・オプション引数

引数が与えられなければ，指定の値を渡す方法



### 値を返却する前の途中終了

#### ・```return;```


```PHP
<?php
function returnMethod()
{
    print "returnMethod()です。\n";
    return; // 何も返さない．
}
```

```PHP
<?php
returnMethod(); // returnMethod()です。
// 処理は続く．
```


#### ・```exit;```

```PHP
<?php
function exitMethod()
{
    print "exitMethod()です。\n";
    exit;
}
```

```PHP
<?php
exitMethod(); // exitMethod()です。
// ここで，システム全体の処理が終了する．
```



### 値の返却

#### ・```return```

メソッドがコールされた場所に値を返却した後，その処理が終わる．

#### ・```yield```

メソッドがコールされた場所に値を返却した後，そこで終わらず，```yield```の次の処理が続く．返却値は，array型である．

**【実装例】**

```PHP
<?php
function getOneToThree(): array
{
    for ($i = 1; $i <= 3; $i++) {
        // yield を返却した後、$i の値が維持される．
        yield $i;
    }
}
```

```PHP
<?php
$oneToThree = getOneToThree();

foreach ($oneToThree as $value) {
    echo "{$value}\n";
}

// 1
// 2
// 3
```



### Dispatcher

#### ・Dispatcherとは

特定の文字列によって，動的にメソッドをコールするオブジェクトをDispatcherという．

```PHP
<?php
$dispatcher = new Dispatcher;

// 文字列とメソッドの登録.
$dispatcher->addListener(string $name, callable $listener)

// 文字列からメソッドをコール.
$dispatcher->dispatch(string $name, $param)
```

#### ・イベント名に紐づくメソッドをコールするオブジェクト

イベント名を文字列で定義し，特定のイベント名が渡された時に，それに対応づけられた関数をコールする．フレームワークの```EventDispatcher```を使用するのがよい

**【実装例】**

```PHP
<?php
use Symfony\Component\EventDispatcher\EventDispatcher;

class ExampleEventDispatcher
{
   // 詳しくは，フレームワークのノートを参照． 
}
```

#### ・計算処理の返却値を保持するオブジェクト

大量のデータを集計するは，その処理に時間がかかる．そこで，そのようなメソッドでは，一度コールされて集計を行った後，データに返却値を保持しておく．そして，再びコールされた時には，返却値をデータから取り出す．

**【実装例】**

```PHP
<?php
class ResultCacher
{
    private $resultCollection;
    
    private $funcCollection;
    
    public function __construct()
    {
        $this->funcCollection = $this->addListener();
    }
  
  
    // 集計メソッド
    public function computeRevenue()
    {
        // 時間のかかる集計処理;
    }

  
    public function funcNameListener(string $funcName)
    {
        // 返却値が設定されていなかった場合，値を設定.
        if (!isset($this->resultCollection[$funcName])) {
            
            // メソッドの返却値をCollectionに設定．
            $this->resultCollection[$funcName] = $this->dispatch($funcName);
        }
        
        // 返却値が設定されていた場合,そのまま使う．
        return $this->resultCollection[$funcName];
    }
  
  
    // 返却値をキャッシュしたいメソッド名を登録しておく．
    private function addListener()
    {
        return [
          "computeRevenue" => [$this, "computeRevenue"]
        ];
    }
  
    
    private function dispatch(string $funcName)
    {
        // call_user_funcでメソッドを実行
        return call_user_func(
          // 登録されているメソッド名から，メソッドをDispatch.
          $this->funcCollection[$funcName]
        );
    }
}
```



## 02-03. 無名関数

特定の処理が，```private```メソッドとして切り分けるほどでもないが，他の部分と明示的に区分けたい時は，無名関数を用いるとよい．

### Closure（無名関数）の定義，変数格納後のコール

#### ・```use()```のみに引数を渡す場合

**【実装例】**

```PHP
<?php
$item = new Item;

// 最初の括弧を用いないことで，普段よくやっている値渡しのメソッドを定義しているのと同じになる．
// use()に，親メソッド（$optionName）のスコープの$itemを渡す．
$optionName = function () use ($item) {
    $item->getOptionName();
};

// function()には引数が設定されていないので，コール時に引数は不要．
echo $optionName;

// 出力結果
// オプションA
```

#### ・```function()```と```use()```に引数を渡す場合

**【実装例】**

```PHP
<?php
$item = new Item;

// 最初の括弧を用いないことで，普段よくやっている値渡しのメソッドを定義しているのと同じになる．
// 親メソッド（$optionName）のスコープの$itemを，use()に渡す．
// $paramは，コール時に使う変数．
$optionName = function ($para) use ($item) {
    $item->getOptionName() . $para;
};

// コール時に，$paramをfunction()に渡す．
echo $optionName("BC");

// 出力結果
// オプションABC
```

#### ・データの値として，無名関数を格納しておく裏技

**【実装例】**

```PHP
<?php
$item = new Item;

// 最初の括弧を用いないことで，普段よくやっている値渡しのメソッドを定義しているのと同じになる．
// use()に，親メソッドのスコープの$itemを渡す．
// $paramは，コール時に使う変数．
$option = new Option;

// データの値に無名関数を格納する．
$option->name = function ($para) use ($item) {
    $item->getOptionName() . $para;
};

// コール時に，$paramをfunction()に渡す．
echo $option->name("BC");

// 出力結果
// オプションABC
```



### Closure（無名関数）の定義と即コール

定義したその場でコールされる無名関数を『即時関数』と呼ぶ．無名関数をコールしたい時は，```call_user_func()```を用いる．

**【実装例】**

```PHP
<?php
$item = new Item;
$param = "BC";

// use()に，親メソッドのスコープの$itemを渡す．
// 無名関数を定義し，同時にcall_user_func()で即コールする．
// $paramは，コール時に使う変数．
$optionName = call_user_func(function ($param) use ($item) {
    $item->getOptionName() . $param;
});

// $paramはすでに即コール時に渡されている．
// これはコールではなく，即コール時に格納された返却値の出力．
echo $optionName;

// 出力結果
// オプションABC
```



### 高階関数とClosure（無名関数）の組み合わせ

関数を引数として受け取ったり，関数自体を返したりする関数を『高階関数』と呼ぶ．

#### ・無名関数を用いない場合

**【実装例】**

```PHP
<?php
// 第一引数のみの場合

// 高階関数を定義
function test($callback)
{
    echo $callback();
}

// コールバックを定義
// 関数の中でコールされるため，「後で呼び出される」という意味合いから，コールバック関数といえる．
function callbackMethod():string
{
    return "出力に成功しました．";
}

// 高階関数の引数として，コールバック関数を渡す
test("callbackMethod");

// 出力結果
// 出力に成功しました．
```

```PHP
<?php
// 第一引数と第二引数の場合

// 高階関数を定義
function higherOrder($param, $callback)
{
    return $callback($param);
}

// コールバック関数を定義
function callbackMethod($param)
{
    return $param."の出力に成功しました．";
}
 
// 高階関数の第一引数にコールバック関数の引数，第二引数にコールバック関数を渡す
higherOrder("第一引数", "callbackMethod");

// 出力結果
// 第一引数の出力に成功しました．
```

#### ・無名関数を用いる場合

**【実装例】**

```PHP
<?php
// 高階関数のように，関数を引数として渡す．
function higherOrder($parentVar, $callback)
{
    $parentVar = "&親メソッドのスコープの変数";
    return $callback($parentVar);
}

// 第二引数の無名関数．関数の中でコールされるため，「後でコールされる」という意味合いから，コールバック関数といえる．
// コールバック関数は再利用されないため，名前をつけずに無名関数とすることが多い．
// 親メソッドのスコープで定義されている変数を引数として渡す．（普段よくやっている値渡しと同じ）
higherOrder($parentVar, function () use ($parentVar) {
    return $parentVar . "の出力に成功しました．";
}
);

// 出力結果
// 親メソッドのスコープの変数の出力に成功しました．
```



### 高階関数を使いこなす！

```PHP
<?php
class Example
{
    
    /**
     * @var array
     */
    protected $properties;

    // 非無名メソッドあるいは無名メソッドを引数で渡す．
    public function Shiborikomi($callback)
    {
        if (!is_callable($callback)) {
            throw new \LogicException;
        }

        // 自身が持つ配列型のデータを加工し，再格納する．
        $properties = [];
        foreach ($this->properties as $property) {

            // 引数の無名関数によって，データに対する加工方法が異なる．
            // 例えば，判定でTRUEのもののみを返すメソッドを渡すと，自データを絞り込むような処理を行える．
            $returned = call_user_func($property, $callback);
            if ($returned) {

                // 再格納．
                $properties[] = $returned;
            }
        }

        // 他のデータは静的に扱ったうえで，自身を返す．
        return new static($properties);
    }
}
```



## 03. データ構造の実装方法

ハードウェアが処理を行う時に，データの集合を効率的に扱うためのデータ格納形式をデータ構造という．データ構造のPHPによる実装方法を以下に示す．

### Array型

同じデータ型のデータを並べたデータ格納様式のこと．

#### ・インデックス配列

番号キーごとに値が格納されたArray型のこと．

```
Array
(
    [0] => A
    [1] => B
    [2] => C
)
```

#### ・多次元配列

配列の中に配列をもつArray型のこと．配列の入れ子構造が２段の場合，『二次元配列』と呼ぶ．

```
( 
    [0] => Array
        (
            [0] => リンゴ
            [1] => イチゴ
            [2] => トマト
        )

    [1] => Array
        (
            [0] => メロン
            [1] => キュウリ
            [2] => ピーマン
        )
)
```

#### ・連想配列

キー名（赤，緑，黄，果物，野菜）ごとに値が格納されたArray型のこと．下の例は，二次元配列かつ連想配列である．

```
Array
(
    [赤] => Array
        (
            [果物] => リンゴ
            [果物] => イチゴ
            [野菜] => トマト
        )

    [緑] => Array
        (
            [果物] => メロン
            [野菜] => キュウリ
            [野菜] => ピーマン
        )
)
```

#### ・配列内の要素の走査（スキャン）

配列内の要素を順に調べていくことを『走査（スキャン）』という．例えば，```foreach()```は，配列内の全ての要素を走査する処理である．下図では，連想配列が表現されている．

![配列の走査](https://raw.githubusercontent.com/Hiroki-IT/tech-notebook/master/images/配列の走査.png)

#### ・内部ポインタを用いた配列要素の出力

『内部ポインタ』とは，配列において，参照したい要素を位置で指定するためのカーソルのこと．

```PHP
<?php
$array = array("あ", "い", "う");

// 内部ポインタが現在指定している要素を出力．
echo current($array); // あ

// 内部ポインタを一つ進め，要素を出力．
echo next($array); // い

// 内部ポインタを一つ戻し，要素を出力．
echo prev($array); // あ

// 内部ポインタを最後まで進め，要素を出力．
echo end($array); // う

// 内部ポインタを最初まで戻し，要素を出力
echo reset($array); // あ
```



### LinkedList型

PHPで用いることはあまりないデータ格納様式．詳しくは，JavaにおけるLinkedList型を参照せよ．

#### ・PHPの```list()```とは何なのか

PHPの```list()```は，List型とは意味合いが異なる．配列の要素一つ一つを変数に格納したい場合，List型を使わなければ，冗長ではあるが，以下のように実装する必要がある．

```PHP
<?php
$array = array("あ", "い", "う");
$a = $array[0];
$i = $array[1];
$u = $array[2];

echo $a.$i.$u; // あいう
```

しかし，以下の様に，```list()```を使うことによって，複数の変数への格納を一行で実装することができる．

```PHP
<?php
list($a, $i, $u) = array("あ", "い", "う");

echo $a.$i.$u; // あいう
```



### Queue型

![Queue1](https://raw.githubusercontent.com/Hiroki-IT/tech-notebook/master/images/Queue1.gif)

![矢印_80x82](https://raw.githubusercontent.com/Hiroki-IT/tech-notebook/master/images/矢印_80x82.jpg)

 

![Queue2](https://raw.githubusercontent.com/Hiroki-IT/tech-notebook/master/images/Queue2.gif)

![矢印_80x82](https://raw.githubusercontent.com/Hiroki-IT/tech-notebook/master/images/矢印_80x82.jpg)

 

![Queue3](https://raw.githubusercontent.com/Hiroki-IT/tech-notebook/master/images/Queue3.gif)

PHPでは，```array_push()```と```array_shift()```を組み合わせることで実装できる．

```PHP
<?php
$array = array("Blue", "Green");

// 引数を，配列の最後に，要素として追加する．
array_push($array, "Red");
print_r($array);

// 出力結果

//	Array
//	(
//		[0] => Blue
//		[1] => Green
//		[2] => Red
//	)

// 配列の最初の要素を取り出す．
$theFirst= array_shift($array);
print_r($array);

// 出力結果

//	Array
//	(
//    [0] => Green
//    [1] => Red
//	)

// 取り出された値の確認
echo $theFirst; // Blue
```

#### ・メッセージQueue

送信側の好きなタイミングでファイル（メッセージ）をメッセージQueueに追加できる．また，受信側の好きなタイミングでメッセージを取り出すことができる．

![メッセージキュー](https://raw.githubusercontent.com/Hiroki-IT/tech-notebook/master/images/メッセージキュー.jpg)



### Stack型

PHPでは，```array_push()```と```array_pop()```で実装可能．

![Stack1](https://raw.githubusercontent.com/Hiroki-IT/tech-notebook/master/images/Stack1.gif)

![矢印_80x82](https://raw.githubusercontent.com/Hiroki-IT/tech-notebook/master/images/矢印_80x82.jpg)

 

![Stack2](https://raw.githubusercontent.com/Hiroki-IT/tech-notebook/master/images/Stack2.gif)

![矢印_80x82](https://raw.githubusercontent.com/Hiroki-IT/tech-notebook/master/images/矢印_80x82.jpg)

 

![Stack3](https://raw.githubusercontent.com/Hiroki-IT/tech-notebook/master/images/Stack3.gif)



### Tree型

#### ・二分探索木

  各ノードにデータが格納されている．

![二分探索木](https://raw.githubusercontent.com/Hiroki-IT/tech-notebook/master/images/二分探索木1.gif)



#### ・ヒープ

  Priority Queueを実現するときに用いられる．各ノードにデータが格納されている．

![ヒープ1](https://raw.githubusercontent.com/Hiroki-IT/tech-notebook/master/images/ヒープ1.gif)

![矢印_80x82](https://raw.githubusercontent.com/Hiroki-IT/tech-notebook/master/images/矢印_80x82.jpg)

![ヒープ1](https://raw.githubusercontent.com/Hiroki-IT/tech-notebook/master/images/ヒープ2.gif)

![矢印_80x82](https://raw.githubusercontent.com/Hiroki-IT/tech-notebook/master/images/矢印_80x82.jpg)

![ヒープ2](https://raw.githubusercontent.com/Hiroki-IT/tech-notebook/master/images/ヒープ3.gif)

![矢印_80x82](https://raw.githubusercontent.com/Hiroki-IT/tech-notebook/master/images/矢印_80x82.jpg)

![. ](https://raw.githubusercontent.com/Hiroki-IT/tech-notebook/master/images/ヒープ4.gif)



## 03-02. Javaにおけるデータ構造の実装方法

データ構造のJavaによる実装方法を以下に示す．

### Array型

#### ・ArrayList

ArrayListクラスによって実装されるArray型．PHPのインデックス配列に相当する．

#### ・HashMap

HashMapクラスによって実装されるArray型．PHPの連想配列に相当する．



### LinkedList型

値をポインタによって順序通り並べたデータ格納形式のこと．

#### ・単方向List

![p555-1](https://raw.githubusercontent.com/Hiroki-IT/tech-notebook/master/images/p555-1.gif)

#### ・双方向List

![p555-2](https://raw.githubusercontent.com/Hiroki-IT/tech-notebook/master/images/p555-2.gif)

#### ・循環List

![p555-3](https://raw.githubusercontent.com/Hiroki-IT/tech-notebook/master/images/p555-3.gif)



### Queue型

### Stack型

### Tree型



## 05-03. データ型

### スカラー型

#### ・int

#### ・float

#### ・string

#### ・boolean

|   T／F    | データの種類 | 説明                     |
| :-------: | ------------ | ------------------------ |
| **FALSE** | ```$var =``` | 何も格納されていない変数 |
|           | ```False```  | 文字としてのFalse        |
|           | ```0```      | 数字、文字列             |
|           | ```""```     | 空文字                   |
|           | array()      | 要素数が0個の配列        |
|           | NULL         | NULL値                   |
| **TRUE**  | 上記以外の値 |                          |



### 複合型


#### ・array

#### ・object

```
Fruit Object
(
    [id:private] => 1
    [name:private] => リンゴ
    [price:private] => 100
)
```



### その他のデータ型

#### ・null

#### ・date

厳密にはデータ型ではないが，便宜上，データ型とする．タイムスタンプとは，協定世界時(UTC)を基準にした1970年1月1日の0時0分0秒からの経過秒数を表したもの．

| フォーマット         | 実装方法            | 備考                                                         |
| -------------------- | ------------------- | ------------------------------------------------------------ |
| 日付                 | 2019-07-07          | 区切り記号なし、ドット、スラッシュなども可能                 |
| 時間                 | 19:07:07            | 区切り記号なし、も可能                                       |
| 日付と時間           | 2019-07-07 19:07:07 | 同上                                                         |
| タイムスタンプ（秒） | 1562494027          | 1970年1月1日の0時0分0秒から2019-07-07 19:07:07 までの経過秒数 |



### キャスト演算子

#### ・```(string)```

```PHP
<?php
$var = 10; // $varはInt型．

// キャスト演算子でデータ型を変換
$var = (string) $var; // $varはString型
```

#### ・```(int)```

```PHP
<?php
// Int型
$var = (int) $var;
```

#### ・```(bool)```

```PHP
<?php
// Boolean型
$var = (bool) $var;
```

#### ・```(float)```

```PHP
<?php
// Float型
$var = (float) $var;
```

#### ・```(array)```

```PHP
<?php
// Array型
$var = (array) $var;
```

#### ・```(object)```

```PHP
<?php
// Object型
$var = (object) $var;
```



## 04. 定数

### 定数が役に立つ場面

計算処理では，可読性の観点から，できるだけ数値を直書きしない．数値に意味合いを持たせ，定数として扱うと可読性が高くなる．例えば，ValueObjectにおける定数がある．

```PHP
<?php
class requiredTime
{
    // 判定値，歩行速度の目安，車速度の目安，を定数で定義する．
    const JUDGMENT_MINUTE = 21;
    const WALKING_SPEED_PER_MINUTE = 80;
    const CAR_SPEED_PER_MINUTE = 400;
    
    
    private $distance;
    
    
    public function __construct(int $distance)
    {
        $this->distance = $distance;
    }
    
    
    public function isMinuteByWalking()
    {
        if ($this->distance * 1000 / self::WALKING_SPEED_PER_MINUTE < self::JUDGMENT_MINUTE) {
            return TRUE;
        }
        
        return FALSE;
    }
    
    
    public function minuteByWalking()
    {
        $minute = $this->distance * 1000 / self::WALKING_SPEED_PER_MINUTE;
        return ceil($minute);
    }
    
    
    public function minuteByCar()
    {
        $minute = $this->distance * 1000 / self::CAR_SPEED_PER_MINUTE;
        return ceil($minute);
    }
}
```



### マジカル定数

自動的に値が格納されている定数．

#### ・```__DIR__```

この定数がコールされたファイルが設置されたディレクトリのパスが，ルートディレクトリ基準で格納されている．

**【実装例】**

以下の実装を持つファイルを，「```/var/www/app```」下に置いておき，「```/vendor/autoload.php```」と結合してパスを通す．

```PHP
<?php
# /var/www/app/vendor/autoload.php
require_once realpath(__DIR__ . '/vendor/autoload.php');
```

#### ・```__FUNCTION__```

この定数がコールされたメソッド名が格納されている．

**【実装例】**

```PHP
<?php
class ExampleA
{
  public function a()
  {
    echo __FUNCTION__;
  }
}
```

```PHP
<?php
$exampleA = new ExmapleA;
$example->a(); // a が返却される．
```

#### ・```__METHOD__```

この定数がコールされたクラス名とメソッド名が，```{クラス名}::{メソッド名}```の形式で格納されている．

**【実装例】**

```PHP
<?php
class ExampleB
{
  public function b()
  {
    echo __METHOD__;
  }
}
```

```PHP
<?php
$exampleB = new ExmapleB;
$exampleB->b(); // ExampleB::b が返却される．
```



## 05. 変数

### 変数展開

文字列の中で，変数の中身を取り出すことを『変数展開』と呼ぶ．

※Paizaで検証済み．

#### ・シングルクオーテーションによる変数展開

シングルクオーテーションの中身は全て文字列として認識され，変数は展開されない．

```PHP
<?php
$fruit = "リンゴ";

// 出力結果
echo 'これは$fruitです．'; // これは，$fruitです．
```

#### ・シングルクオーテーションと波括弧による変数展開

シングルクオーテーションの中身は全て文字列として認識され，変数は展開されない．

```PHP
<?php
$fruit = "リンゴ";

// 出力結果
echo 'これは{$fruit}です．'; // これは，{$fruit}です．
```

#### ・ダブルクオーテーションによる変数展開

変数の前後に半角スペースを置いた場合にのみ，変数は展開される．（※半角スペースがないとエラーになる）

```PHP
<?php
$fruit = "リンゴ";

// 出力結果
echo "これは $fruit です．"; // これは リンゴ です．
```

#### ・ダブルクオーテーションと波括弧による変数展開

波括弧を用いると，明示的に変数として扱うことができる．これによって，変数の前後に半角スペースを置かなくとも，変数は展開される．

```PHP
<?php
$fruit = "リンゴ";

// 出力結果
echo "これは{$fruit}です．"; // これは，リンゴです．
```



### 参照渡しと値渡し

#### ・参照渡し

「参照渡し」とは，変数に代入した値の参照先（メモリアドレス）を渡すこと．

```PHP
<?php
$value = 1;
$result = &$value; // 値の入れ物を参照先として代入
```

**【実装例】**```$b```には，```$a```の参照によって10が格納される．

```PHP
<?php
$a = 2;
$b = &$a;  // 変数aを&をつけて代入
$a = 10;    // 変数aの値を変更

// 出力結果
echo $b; // 10
```

#### ・値渡し

「値渡し」とは，変数に代入した値のコピーを渡すこと．

```PHP
<?php
$value = 1;
$result = $value; // 1をコピーして代入
```

**【実装例】**```$b```には，```$a```の一行目の格納によって2が格納される．

```PHP
<?php
$a = 2;
$b = $a;  // 変数aを代入
$a = 10;  // 変数aの値を変更


// 出力結果
echo $b; // 2
```



## 06. その他の組み込み関数

### ファイルシステム

#### ・ファイルに文字列を出力

**【実装例】**

```php
$array = [];

// array型をJSON型に変換
$json = json_encode($array);

// fopen()，fwrite()，fclose()を実行できる．
file_put_contents(
    'data.json',
    $json
);
```



## 07. 正規表現とパターン演算子

### 正規表現

#### ・正規表現を用いた文字列検索

```PHP
// ここに実装例
```



### パターン演算子

#### ・オプションとしてのパターン演算子

```PHP
<?php
// jpegの大文字小文字
preg_match(
    '/jpeg$/i',
    $x
);
```

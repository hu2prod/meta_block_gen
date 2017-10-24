# meta_block_gen
Abstracted block_gen. No specific logic. Just pure blocks.

 * Мотивация. Почему вообще есть этот модуль
   * Модульность в коде достаточно сложно поддерживать.
   * Не всегда можно легко вынуть какую-то часть и заменить её на другую (попробуй выкинуть из scriptscript hereregex, придется по 3-4 файлам полазить)
   * Не всегда можно указать другой параметр сборки (Привет флаги в gentoo)
   * Есть еще ПЛИСы. У них компоненты располагаются по логике модулей, которые нужно подключать друг с другом. И там прекрасная декомпозиция.
   * Почему нельзя собрать большого монстра из небольших (до 100 строк кода) кусочков, которые сгенерируют большой код. Иногда включая тесты.
 * Что есть в модуле
   * `Block` - то с чего мы всё строим
     * особый блок `Block` верхнего уровня, который не имеет `parent`
   * `Block_blueprint` - чертеж блока. По факту генератор, которому передаешь параметры, и он тебе генерирует блок.
   * Есть блоки, у которых уже сразу есть `child_list` и его менять нельзя.
   * Есть блоки, у которых можно вызвать `inject` и добавить туда `child`ren'ов
   * У блока есть 2 стадии генерации `compile` и `flush`
     * При compile могут создаваться новые блоки. Проходится полностью дерево, создает блоки. Возможно, генерирует какой-то код.
     * При flush все исходные коды записываются в соответствующие файлы [пример блока](https://github.com/hu2prod/meta_block_gen/blob/master/src/file_gen.coffee#L10)
   * `Block_blueprint_collection` является "репизиторием четрежей блоков". Туда можно подобрасывать нужные блоки, а потом оттуда происходит их генерация.
   * Есть 2 функции. Декларация блока `autogen` и генерация блока `gen`
   * Для декларации нужно указать
     * имя блока (которое будет просто в поле `name`)
     * regexp на который будет отзываться этот генератор
     * функцию-генератор. Ей передается блок, и она должна создать в нем все нужные внутренности. (И хорошим тоном является вернуть блок через return, но это необязательно/дань моде)
   * Для генерации нужно вызвать `gen` с именем блока
   * Зачем нужен regexp?
     * В блоках могут быть параметры.
     * Имя блока описывает семейство
     * Конкретный блок может быть специализирован под конкретную задачу. Пример. sum_32. /^sum_(\d+)$/.
   
# Пример создания генератора нового блока

    parent = collection.auto_gen 'parent_test', /^parent_test$/, (ret)->
      ret.hash.param1 = true
      ret.compile_fn = ()->
        # some actions
      ret.flush_fn = ()->
        # some actions
      ret

Важно указывать в regexp начало ^ и конец $ строки. Дабы случайно оно не вызвалось для не своего блока.

    collection.param_hash = # порядок важен !!!
      a : 'int'
    parent = collection.auto_gen 'parent_test', /^parent_test_(\d+)$/, (ret)->
      # тут будет доступен ret.param_hash.a в котором будет parseInt от соответствующей позиции в регулярке

# Пример создания нового блока

    parent = collection.gen 'parent_test'

# Пример `inject`

    parent = collection.gen 'parent_test'
    parent.inject ()->
      collection.gen 'child_test'

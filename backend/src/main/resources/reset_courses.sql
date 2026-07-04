-- ===========================================
-- 课程数据重置脚本
-- 请先执行 DELETE 清理，再执行 INSERT 重建
-- ===========================================

-- 清理旧数据（注意顺序：先删子表，再删主表）
DELETE FROM `user_course_progress`;
DELETE FROM `question`;
DELETE FROM `course_section`;
DELETE FROM `course`;

-- 重置自增ID
ALTER TABLE `course` AUTO_INCREMENT = 1;
ALTER TABLE `course_section` AUTO_INCREMENT = 1;
ALTER TABLE `question` AUTO_INCREMENT = 1;
ALTER TABLE `user_course_progress` AUTO_INCREMENT = 1;

-- ========== 课程数据（ID 1-4）==========
INSERT INTO `course` (`name`, `description`, `skill_id`, `teacher_id`, `difficulty_level`, `sort_order`, `status`) VALUES
('JavaScript 核心语法与实战', '从零开始学习 JavaScript，涵盖变量、数据类型、函数、闭包等核心概念', 1, 2, 1, 1, 1),
('Vue3 组件化开发', '系统学习 Vue3 组合式 API、组件通信、路由和状态管理', 2, 2, 3, 2, 1),
('Python 编程入门', 'Python 基础语法、数据结构、面向对象编程和文件操作', 3, 2, 1, 3, 1),
('Spring Boot 企业级开发', 'Spring Boot 核心原理、RESTful API、数据访问和安全性配置', 4, 2, 4, 4, 1);

-- ========== 章节数据（ID 1-10）==========
INSERT INTO `course_section` (`course_id`, `title`, `description`, `order_index`) VALUES
-- JavaScript 课程 (course_id=1) → section_id: 1,2,3
(1, '变量与数据类型', 'JavaScript 的基本数据类型和变量声明', 1),
(1, '函数与作用域', '函数定义方式、作用域链和闭包', 2),
(1, '数组与对象', '数组方法、对象操作和 JSON', 3),
-- Vue3 课程 (course_id=2) → section_id: 4,5
(2, '组合式 API 入门', 'ref、reactive、computed 和 watch 的使用', 1),
(2, '组件通信', 'props、emit、provide/inject 和插槽', 2),
-- Python 课程 (course_id=3) → section_id: 6,7,8
(3, '基础语法', 'Python 缩进规则、变量和基本输入输出', 1),
(3, '数据结构', '列表、元组、字典和集合的使用', 2),
(3, '函数与模块', '函数定义、参数传递和模块导入', 3),
-- Spring Boot 课程 (course_id=4) → section_id: 9,10
(4, '项目初始化', '使用 Spring Initializr 创建项目和基本配置', 1),
(4, 'RESTful API 开发', 'Controller、Service、Repository 分层开发', 2);

-- ========== 题目数据 ==========
-- JavaScript 第1章 (section_id=1) - 10题
INSERT INTO `question` (`section_id`, `content`, `type`, `options`, `correct_answer`, `analysis`, `order_index`) VALUES
(1, '以下哪个关键字用于声明常量？', 'choice', '["var","let","const","static"]', 'const', 'const 用于声明常量，一旦赋值不可修改', 1),
(1, 'typeof null 的返回值是什么？', 'choice', '["null","undefined","object","boolean"]', 'object', '这是 JavaScript 的一个历史遗留 bug', 2),
(1, '以下哪个不是 JavaScript 的基本数据类型？', 'choice', '["string","number","boolean","array"]', 'array', 'array 是引用类型，不是基本数据类型', 3),
(1, 'undefined == null 的结果是？', 'choice', '["true","false","报错","undefined"]', 'true', '非严格相等(==)下两者等值', 4),
(1, 'JavaScript 是编译型语言。', 'true_false', NULL, 'false', 'JavaScript 是解释型语言', 5),
(1, 'let 声明的变量存在暂时性死区。', 'true_false', NULL, 'true', 'let 和 const 声明的变量在声明前不可访问', 6),
(1, '使用 const 声明的对象，其属性值不能被修改。', 'true_false', NULL, 'false', 'const 保证的是引用地址不变，但属性可以被修改', 7),
(1, 'typeof typeof 42 的结果是什么？', 'choice', '["number","string","undefined","boolean"]', 'string', 'typeof 42 → "number", typeof "number" → "string"', 8),
(1, '0.1 + 0.2 === 0.3 的结果是？', 'choice', '["true","false","报错","undefined"]', 'false', '浮点数精度问题：0.1+0.2≠0.3', 9),
(1, 'NaN === NaN 的结果是？', 'choice', '["true","false","报错","undefined"]', 'false', 'NaN 是唯一一个与自己不相等的值', 10);

-- JavaScript 第2章 (section_id=2) - 6题
INSERT INTO `question` (`section_id`, `content`, `type`, `options`, `correct_answer`, `analysis`, `order_index`) VALUES
(2, '以下哪种方式定义的函数会被提升？', 'choice', '["函数表达式","箭头函数","函数声明","以上都会"]', '函数声明', '函数声明会被整体提升到作用域顶部', 1),
(2, '箭头函数和普通函数的主要区别是什么？', 'choice', '["语法更简洁","没有自己的this","不能有返回值","不能传参"]', '没有自己的this', '箭头函数不绑定自己的 this', 2),
(2, '以下代码输出什么？ for(var i=0;i<3;i++){setTimeout(()=>console.log(i),100)}', 'choice', '["0 1 2","3 3 3","0 0 0","undefined"]', '3 3 3', 'var 声明的 i 是函数级作用域，循环结束 i=3', 3),
(2, '以下关于闭包的说法正确的是？', 'choice', '["闭包会释放外部变量","闭包可以访问外部函数的变量","箭头函数不能形成闭包","闭包只在浏览器中存在"]', '闭包可以访问外部函数的变量', '闭包是指内部函数可以访问外部函数作用域中的变量', 4),
(2, 'call() 和 apply() 都可以指定 this。', 'true_false', NULL, 'true', '两者都可以显式指定函数执行时的 this 值', 5),
(2, '闭包会导致变量无法被垃圾回收。', 'true_false', NULL, 'true', '闭包会保持对外部变量的引用，可能导致内存泄漏', 6);

-- JavaScript 第3章 (section_id=3) - 4题
INSERT INTO `question` (`section_id`, `content`, `type`, `options`, `correct_answer`, `analysis`, `order_index`) VALUES
(3, '以下哪个数组方法会改变原数组？', 'choice', '["map()","filter()","push()","reduce()"]', 'push()', 'push() 直接修改原数组，map/filter/reduce 返回新数组', 1),
(3, 'Array.from() 可以将类数组对象转为数组。', 'true_false', NULL, 'true', 'Array.from() 能将类数组对象或可迭代对象转为真正的数组', 2),
(3, '展开运算符(...)可以用来复制数组。', 'true_false', NULL, 'true', '使用 [...arr] 可以浅拷贝一个数组', 3),
(3, 'JSON.stringify() 可以处理 function 类型的数据。', 'true_false', NULL, 'false', 'JSON.stringify() 会忽略函数类型的值', 4);

-- Vue3 第1章 (section_id=4) - 5题
INSERT INTO `question` (`section_id`, `content`, `type`, `options`, `correct_answer`, `analysis`, `order_index`) VALUES
(4, 'ref 可以处理基本类型和对象，reactive 只能处理对象', 'choice', '["正确","错误"]', '正确', 'ref 可以包裹基本类型和对象，reactive 只接受对象类型', 1),
(4, 'computed 和 watch 的区别是？', 'choice', '["computed 是异步的","computed 有缓存，watch 没有","两者完全一样"]', 'computed 有缓存，watch 没有', 'computed 基于依赖缓存，只有依赖变化才重新计算；watch 每次变化都执行', 2),
(4, '以下哪个不是 Vue3 生命周期钩子？', 'choice', '["onMounted","onCreated","onUnmounted","onBeforeMount"]', 'onCreated', '组合式 API 中用 setup() 代替了 beforeCreate 和 created 钩子', 3),
(4, 'Vue3 的 setup() 函数中可以访问 this。', 'true_false', NULL, 'false', 'setup() 在组件创建前执行，此时组件实例尚未创建', 4),
(4, 'ref 在模板中自动解包，无需写 .value。', 'true_false', NULL, 'true', '在模板中使用 ref 时，Vue 会自动解包', 5);

-- Vue3 第2章 (section_id=5) - 3题
INSERT INTO `question` (`section_id`, `content`, `type`, `options`, `correct_answer`, `analysis`, `order_index`) VALUES
(5, '子向父传递数据应该使用？', 'choice', '["props","emit","provide/inject","slot"]', 'emit', '子组件通过 emit 触发事件，父组件监听接收', 1),
(5, '关于 Vue3 插槽的说法错误的是？', 'choice', '["具名插槽用 name 标识","作用域插槽可访问子组件数据","插槽只能传递文本","插槽可设置默认内容"]', '插槽只能传递文本', '插槽可以传递任何模板内容', 2),
(5, 'provide/inject 适合什么场景？', 'choice', '["父子通信","深层级组件传值","兄弟通信","跨页面传值"]', '深层级组件传值', 'provide/inject 主要用于深层嵌套组件之间传值', 3);

-- Python 第1章 (section_id=6) - 4题
INSERT INTO `question` (`section_id`, `content`, `type`, `options`, `correct_answer`, `analysis`, `order_index`) VALUES
(6, 'Python 代码块用什么表示开始和结束？', 'choice', '["中括号{}","缩进","begin/end","括号()"]', '缩进', 'Python 使用缩进表示代码块层次结构', 1),
(6, 'print(10 // 3) 的输出是什么？', 'choice', '["3.33","3","3.0","报错"]', '3', '// 是整数除法运算符，向下取整', 2),
(6, 'Python 是强类型语言。', 'true_false', NULL, 'true', 'Python 是强类型语言，不会隐式类型转换', 3),
(6, 'Python 变量不需要声明类型。', 'true_false', NULL, 'true', 'Python 是动态类型语言，类型由赋值自动推断', 4);

-- Python 第2章 (section_id=7) - 3题
INSERT INTO `question` (`section_id`, `content`, `type`, `options`, `correct_answer`, `analysis`, `order_index`) VALUES
(7, '以下哪个数据是可变的？', 'choice', '["元组","字符串","列表","整数"]', '列表', '列表是可变的，元组/字符串/数字不可变', 1),
(7, '字典的键必须是什么类型？', 'choice', '["可变类型","不可变类型","任意类型","字符串"]', '不可变类型', '字典的键必须是不可变类型', 2),
(7, '集合中的元素是有序不重复的。', 'true_false', NULL, 'false', '集合中的元素是无序的，但元素不重复', 3);

-- Python 第3章 (section_id=8) - 2题
INSERT INTO `question` (`section_id`, `content`, `type`, `options`, `correct_answer`, `analysis`, `order_index`) VALUES
(8, '*args 表示什么？', 'choice', '["关键字参数","可变位置参数","默认参数","仅限关键字参数"]', '可变位置参数', '*args 接收任意数量的位置参数', 1),
(8, 'Python 用什么关键字导入模块？', 'choice', '["include","import","using","require"]', 'import', 'Python 使用 import 导入模块', 2);

-- Spring Boot 第1章 (section_id=9) - 3题
INSERT INTO `question` (`section_id`, `content`, `type`, `options`, `correct_answer`, `analysis`, `order_index`) VALUES
(9, '入口类使用哪个注解？', 'choice', '["@SpringConfiguration","@SpringBootApplication","@SpringBootApp","@EnableAutoConfiguration"]', '@SpringBootApplication', '@SpringBootApplication 是核心注解，组合了 @Configuration、@EnableAutoConfiguration 和 @ComponentScan', 1),
(9, 'application.yml 的用途？', 'choice', '["编写业务代码","存放配置","定义路由","管理依赖"]', '存放配置', 'application.yml 用于配置数据源、端口、日志等', 2),
(9, 'Spring Boot 默认内嵌的 Web 服务器是？', 'choice', '["Tomcat","Jetty","Undertow","Netty"]', 'Tomcat', 'Spring Boot 默认内嵌 Tomcat', 3);

-- Spring Boot 第2章 (section_id=10) - 2题
INSERT INTO `question` (`section_id`, `content`, `type`, `options`, `correct_answer`, `analysis`, `order_index`) VALUES
(10, '@RestController 的作用？', 'choice', '["返回视图","返回JSON数据","返回HTML","返回文件"]', '返回JSON数据', '@RestController = @Controller + @ResponseBody', 1),
(10, '@Autowired 是什么注入方式？', 'choice', '["构造器注入","Setter注入","字段注入","接口注入"]', '字段注入', '@Autowired 默认是字段注入', 2);

import{_ as v,c as p,b as t,w as n,g as o,a8 as _,o as f,a as e,I as r,a2 as i,i as l,a9 as m,aa as x,r as g}from"./index-Bn3JriJA.js";const b={class:"page-container"},k={class:"counter-area"},C={class:"counter-number"},E={class:"counter-actions"},y={class:"explanation"},B={class:"code-example"},h={__name:"index",setup(w){const s=g(0),c=()=>{s.value++},d=()=>{s.value--},u=()=>{s.value=0};return(N,a)=>(f(),p("div",b,[t(o(_),{shadow:"hover"},{header:n(()=>[...a[0]||(a[0]=[e("div",{class:"page-header"},[e("span",{class:"page-title"},"计数器 - ref 响应式示例")],-1)])]),default:n(()=>[e("div",k,[e("div",{class:"counter-display",onClick:c},[e("span",C,r(s.value),1),a[1]||(a[1]=e("span",{class:"counter-hint"},"点击数字 +1",-1))]),e("div",E,[t(o(i),{type:"danger",onClick:d},{default:n(()=>[...a[2]||(a[2]=[l("-1",-1)])]),_:1}),t(o(i),{onClick:u},{default:n(()=>[...a[3]||(a[3]=[l("重置",-1)])]),_:1})])]),t(o(m),null,{default:n(()=>[...a[4]||(a[4]=[l("ref 与 reactive 的区别",-1)])]),_:1}),e("div",y,[t(o(x),{title:"ref 使用场景",type:"info",closable:!1,description:"ref 用于定义基本类型数据（字符串、数字、布尔值等）。在 JavaScript 中需要通过 .value 访问和修改值，但在模板中可以直接使用变量名。"}),e("div",B,[e("pre",null,[e("code",null,`// 定义响应式数据
const count = ref(0)

// 在 JavaScript 中访问/修改（必须加 .value）
console.log(count.value)  // 0
count.value++              // 1

// 在模板中直接使用（不需要 .value）
// <div>`+r(s.value)+"</div>",1)])])])]),_:1})]))}},V=v(h,[["__scopeId","data-v-66b7b75e"]]);export{V as default};

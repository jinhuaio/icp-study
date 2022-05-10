import { counter } from "../../declarations/counter";

//页面加载时，初始化显示计数器数值。
 (async function () {
  const count = await counter.getCounter();
  document.getElementById("current-count").innerText = count;
})()

//调用计数器增加方法。
window.counterInc = async function counterInc() {

    const button = document.getElementById("button-inc");

    button.setAttribute("disabled", true);

    await counter.incCounter();

    const count = await counter.getCounter();

    document.getElementById("current-count").innerText = count;

    button.removeAttribute("disabled");
}

//调用初始化设置计数器方法。
window.initSettingCounter = async function initSettingCounter() {

  const button = document.getElementById("button-init");

  button.setAttribute("disabled", true);

  const initCount = document.getElementById("init-counter").value;

  await counter.setCounter(Number(initCount));

  const queryCount = await counter.getCounter();

  document.getElementById("current-count").innerText = queryCount;
  
  button.removeAttribute("disabled");
}

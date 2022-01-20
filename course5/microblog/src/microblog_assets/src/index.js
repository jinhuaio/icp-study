import { microblog } from "../../declarations/microblog";
export const canisterId = process.env.MICROBLOG_CANISTER_ID;

// document.querySelector("form").addEventListener("submit", async (e) => {
//   e.preventDefault();
//   const button = e.target.querySelector("button");

//   const name = document.getElementById("name").value.toString();

//   button.setAttribute("disabled", true);

//   // Interact with foo actor, calling the greet method
//   const greeting = await microblog.greet(name);

//   button.removeAttribute("disabled");

//   document.getElementById("greeting").innerText = greeting;

//   return false;
// });

function getdate(time) {
  var t = Number(time / 1000000n);
  var ns =Number(time % 1000000n);
  var now = new Date(t),
        y = now.getFullYear(),
        m = now.getMonth() + 1,
        d = now.getDate();
  return y + "-" + (m < 10 ? "0" + m : m) + "-" + (d < 10 ? "0" + d : d) + " " + now.toTimeString().substr(0, 8) + " " + ns;
}

async function post() {
  let post_button = document.getElementById("post");
  post_button.disabled = true;
  let textarea = document.getElementById("message");
  let text = textarea.value;
  let pass = document.getElementById("pass");
  try {
    await microblog.post(text,pass.value.toString());
    textarea.value = "";
  } catch (error) { 
    alert("发送失败，请检查密码是否正确\n" + error);
  }
  post_button.disabled = false;
  
}

var num_posts = 0;
async function load_posts() {
  try {
    let posts = await microblog.posts(0);
    if (num_posts == posts.length) return; 
    num_posts = posts.length;
    tableDisplay("posts",posts);
  } catch (e) {
    console.warn("load_posts: " + e);
  }
}

function tableDisplay(sectionId,messages) {
  // 获取table位置标签
  let table_section = document.getElementById(sectionId);
  table_section.replaceChildren([]);
  // 创建表节点 和tbody节点
  var tbl     = document.createElement("table");
  var tblBody = document.createElement("tbody");
  for (var j = 0; j < messages.length; j++) {
      // 添加行tr
      var row = document.createElement("tr");
      let msgItem = messages[j];

      var cell2 = document.createElement("td");
        cell2.style.border=0;
        cell2.style.cellspacing="0";
        cell2.style.cellpadding="0";
        var cellText2 = document.createTextNode(" # "+j + " # Post Time ："+getdate(msgItem.time) + " ");
        cell2.appendChild(cellText2);
        row.appendChild(cell2);
        
        var cell1 = document.createElement("td");
        cell1.style.border=0;
        cell1.style.cellspacing="0";
        cell1.style.cellpadding="0";
        var cellText1 = document.createTextNode("Author："+msgItem.author);
        cell1.appendChild(cellText1);
        row.appendChild(cell1);
      // 增加到tbody
      tblBody.appendChild(row);

      var row2 = document.createElement("tr");
      // 添加列td: msg
      var cell = document.createElement("td");
      cell.style.border=0;
      cell.style.cellspacing="0";
      cell.style.cellpadding="0";
      cell.colSpan="2";
      var cellText = document.createTextNode(msgItem.content);
      cell.appendChild(cellText);
      row2.appendChild(cell);
      // 增加到tbody
      tblBody.appendChild(row2);
  }
  // 把tbody放入table中
  tbl.appendChild(tblBody);
  // table put to body
  table_section.appendChild(tbl);
  tbl.setAttribute("border", "0");
}

var author_name = "";
async function load_author_name() {
  let my_blog_section = document.getElementById("my_blog");
  let author_name_section = document.getElementById("author_name");
  var name = "";
  try {
    name = await microblog.get_name();
  } catch (e) {
    console.warn("load_author_name: " + e);
  }
  
  if (author_name == name) return;
  author_name = (name == null ? "?" : name);

  my_blog_section.innerText = author_name;
  author_name_section.replaceChildren([]);
  let namep = document.createElement("a");
  namep.innerText = author_name;
  author_name_section.appendChild(namep);

  my_blog_section.replaceChildren([]);
  let blog = document.createElement("a");
  blog.innerText = author_name;
  my_blog_section.appendChild(blog);
}

function load_canisterid() {
  let canid = document.getElementById("canisterid");
  canid.replaceChildren([]);
  let namep = document.createElement("a");
  namep.innerText = canisterId;
  canid.appendChild(namep);
}

var num_follows = 0;
async function load_follows() {
  var follows = null;
  try {
    follows = await microblog.follows();
  } catch (e) {
    console.warn("load_follows: " + e);
  }
  if (follows == null || num_follows == follows.length) return; 
  num_follows = follows.length;
  followsDisplay(follows);
}

// 显示关注列表。
function followsDisplay(follows) {
  // 获取table位置标签
  let follows_section = document.getElementById("follows");
  follows_section.replaceChildren([]);
  // 创建表节点 和tbody节点
  var tbl     = document.createElement("table");
  var tblBody = document.createElement("tbody");
  for (var j = 0; j < follows.length; j++) {
      // 添加行tr
      var row = document.createElement("tr");
      let follow = follows[j];

      var cell2 = document.createElement("td");
        cell2.style.border=0;
        cell2.style.cellspacing="0";
        cell2.style.cellpadding="0";
        var cellText2 = document.createTextNode(" # "+j + " # CanisterID ："+follow.pid + " ");
        cell2.appendChild(cellText2);
        row.appendChild(cell2);
        
        var cell1 = document.createElement("td");
        cell1.style.border=0;
        cell1.style.cellspacing="0";
        cell1.style.cellpadding="0";
        var cellText1 = document.createElement("button");
        cellText1.innerText = "Name: " + follow.author;
        cellText1.setAttribute("pid",follow.pid); 
        cellText1.setAttribute("blogName",follow.author); 
        cell1.appendChild(cellText1);
        row.appendChild(cell1);
      // 增加到tbody
      tblBody.appendChild(row);
  }
  // 把tbody放入table中
  tbl.appendChild(tblBody);
  // table put to body
  follows_section.appendChild(tbl);
  tbl.setAttribute("border", "0");

  var tdb = document.querySelectorAll("td button");
  var ii;
  for (ii = 0; ii < tdb.length; ii++) {
     tdb[ii].addEventListener("click", async (e) => {
      e.preventDefault();
      let pid = e.target.getAttribute("pid");
      let name = e.target.getAttribute("blogName");
      let blogName = document.getElementById("blogName");
      blogName.innerText = "  Loading for " + name + " ... ";
      let table_section = document.getElementById("timeline");
      table_section.replaceChildren([]);
      let count = await load_timeline(pid);
      blogName.innerText = "  found " + count + " article from " + name;
      return false;
    });
  };
}

async function load_timeline(cid) {
  var posts = null;
  let blogName = document.getElementById("blogName");
  if (cid == "") {
    blogName.innerText = "  Loading ... ";
  }
  try{
    posts = await microblog.timeline(cid,0);
  } catch (e) {
    console.warn("load_timeline: " + e);
  }
  if (posts == null) {
    blogName.innerText = "  found 0 article ";
    return 0;
  } else {
    blogName.innerText = "  found " + posts.length + " article ";
  }
  tableDisplay("timeline",posts);
  return posts.length;
}

function loadInterval() {
  load_follows();
  load_posts();
}

function load() {
  let post_button = document.getElementById("post");
  post_button.onclick = post;
  load_canisterid();
  load_posts();
  load_follows();
  load_author_name();
  load_timeline("");
  setInterval(loadInterval,3000);
}

window.onload = load



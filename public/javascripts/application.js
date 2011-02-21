// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults

// Node_Click関数
  // ... 引数 idChild : 子要素の id
  // ... 引数 idClose : 閉じたフォルダ用アイコンを表示する img 要素の id
  // ... 引数 idOpen : 開いたフォルダ用アイコンを表示する img 要素の id
  function Node_Click(idChild, idClose, idOpen)
  {
      if (!document.getElementById) return;
      var objChild = document.getElementById(idChild);
      var objClose = document.getElementById(idClose);
      var objOpen = document.getElementById(idOpen);
      if (objChild.style.display=="none")  {
          objChild.style.display = "block";
          objClose.style.display = "none";
          objOpen.style.display = "inline";
      } else {
          objChild.style.display = "none";
          objClose.style.display = "inline";
          objOpen.style.display = "none";
      }
  }


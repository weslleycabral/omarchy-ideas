var strings = {
  en: {
    ideas: "Ideas (%1)",
    newIdea: "New idea",
    add: "+ New",
    copy: "Copy",
    remove: "Delete",
    back: "Back",
    empty: "No ideas yet — press N",
    placeholder: "Write your idea… the AI fixes it and adds a title.",
    footerNew: "Enter saves · Shift+Enter new line · Esc closes",
    footerList: "↑↓ move · Enter opens · N new · Esc closes",
    footerDetail: "Del deletes · Esc back",
    fixedBy: "fixed by %1",
    fixing: "fixing…",
    one: "1 idea",
    many: "%1 ideas",
    rightNew: "right-click: new",
    dateFormat: "yyyy-MM-dd HH:mm"
  },
  pt: {
    ideas: "Ideias (%1)",
    newIdea: "Nova ideia",
    add: "+ Nova",
    copy: "Copiar",
    remove: "Excluir",
    back: "Voltar",
    empty: "Nenhuma ideia ainda — aperte N",
    placeholder: "Escreva a ideia… a IA corrige e cria o título.",
    footerNew: "Enter salva · Shift+Enter nova linha · Esc fecha",
    footerList: "↑↓ navega · Enter abre · N nova · Esc fecha",
    footerDetail: "Del exclui · Esc volta",
    fixedBy: "corrigida por %1",
    fixing: "corrigindo…",
    one: "1 ideia",
    many: "%1 ideias",
    rightNew: "direito: nova",
    dateFormat: "dd/MM/yyyy HH:mm"
  },
  es: {
    ideas: "Ideas (%1)",
    newIdea: "Nueva idea",
    add: "+ Nueva",
    copy: "Copiar",
    remove: "Eliminar",
    back: "Volver",
    empty: "Aún no hay ideas — pulsa N",
    placeholder: "Escribe tu idea… la IA la corrige y le pone título.",
    footerNew: "Enter guarda · Shift+Enter nueva línea · Esc cierra",
    footerList: "↑↓ navega · Enter abre · N nueva · Esc cierra",
    footerDetail: "Supr elimina · Esc vuelve",
    fixedBy: "corregida por %1",
    fixing: "corrigiendo…",
    one: "1 idea",
    many: "%1 ideas",
    rightNew: "clic derecho: nueva",
    dateFormat: "dd/MM/yyyy HH:mm"
  },
  fr: {
    ideas: "Idées (%1)",
    newIdea: "Nouvelle idée",
    add: "+ Nouvelle",
    copy: "Copier",
    remove: "Supprimer",
    back: "Retour",
    empty: "Aucune idée pour l'instant — appuyez sur N",
    placeholder: "Écrivez votre idée… l'IA la corrige et lui donne un titre.",
    footerNew: "Entrée enregistre · Maj+Entrée nouvelle ligne · Échap ferme",
    footerList: "↑↓ naviguer · Entrée ouvre · N nouvelle · Échap ferme",
    footerDetail: "Suppr supprime · Échap retour",
    fixedBy: "corrigée par %1",
    fixing: "correction…",
    one: "1 idée",
    many: "%1 idées",
    rightNew: "clic droit : nouvelle",
    dateFormat: "dd/MM/yyyy HH:mm"
  }
}

function resolve(code) {
  code = String(code || "").slice(0, 2).toLowerCase()
  return strings[code] ? code : "en"
}

function t(lang, key, arg) {
  var text = strings[resolve(lang)][key]
  return arg === undefined ? text : text.replace("%1", arg)
}

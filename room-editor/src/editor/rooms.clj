(ns editor.rooms)

(def room-width 16)
(def room-height 16)

(def empty-room
  {:definition (repeat (* room-width room-height) " ")})

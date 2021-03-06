(ns editor.app
  (:use seesaw.core
        editor.core
        [seesaw.chooser :only [choose-file]]
        [editor.rooms :only [room-width room-height]])
  (:require [cheshire.core :as json]
            [seesaw.bind :as b]
            [seesaw.color :as color]
            [editor.editor :as editor]
            [editor.room-management :as rms]
            [editor.tools :as tools]
            [editor.rooms :as rooms])
  (:import java.awt.FileDialog))

(def base-dir "../app/coffee/game")

(defn -main [& args]
  (let [app {:model (atom {:rooms []})
             :state (atom {})}
        root (frame :title "Room Editor")
        rooms (rms/create-browser app)
        load-action (action
                      :handler (fn [e]
                                 (when-let [file (choose-file
                                                   :dir base-dir)]
                                   (load-data-file file app)))
                      :name "Load..."
                      :key "menu L")
        save-action (action
                      :handler (fn [e]
                                 (when-let [file (choose-file
                                                   :dir base-dir
                                                   :type :save
                                                   :filters [["Coffee" [".coffee"]]])]
                                   (swap! (:model app) update-in [:rooms] rooms/augment)
                                   (save-data-file file app)))
                      :name "Save..."
                      :key "menu S")]
  (invoke-later
    (-> root
      (config! :menubar
               (menubar
                 :items [(menu
                           :text "File"
                           :items [save-action
                                   load-action])]))
      (config! :content
               (left-right-split
                 (left-right-split
                   (top-bottom-split
                     (vertical-panel
                       :items (tools/create-list app root))
                     (vertical-panel
                       :id :tool-options))
                   (editor/create app))
                 (vertical-panel
                   :items [(label "Rooms")
                           rooms])))
      pack!
      show!))))

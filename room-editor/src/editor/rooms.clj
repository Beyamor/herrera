(ns editor.rooms)

(def room-width 16)
(def room-height 16)

(def directions #{:north :south :east :west})

(defn get-tile
  [definition i j]
  (get definition (+ i (* j room-width))))

(defn set-tile
  [definition i j value]
  (assoc definition (+ i (* j room-width)) value))

(def empty-room
  {:definition
   (->> " "
     (repeat (* room-width room-height))
     vec)})

(defn scan-check
  [definition tile i j]
  (let [this-tile (get-tile definition i j)]
    (condp = this-tile
      tile  [i j]
      " "   :continue
      nil)))

(defn scan-for
  [definition tile direction]
  (let [scan-check (partial scan-check definition tile)]
    (->>
      (case direction
        :north  (for [i (range room-width)]
                  (loop [j 0]
                    (when-let [result (scan-check i j)]
                      (if (= result :continue)
                        (when (< j (dec room-height))
                          (recur (inc j)))
                        result))))

        :south (for [i (range room-width)]
                 (loop [j (dec room-height)]
                   (when-let [result (scan-check i j)]
                     (if (= result :continue)
                       (when (> j 0)
                         (recur (dec j)))
                       result))))

        :west (for [j (range room-height)]
                (loop [i 0]
                  (when-let [result (scan-check i j)]
                    (if (= result :continue)
                      (when (< i (dec room-width))
                        (recur (inc i)))
                      result))))

        :east (for [j (range room-height)]
                 (loop [i (dec room-width)]
                   (when-let [result (scan-check i j)]
                     (if (= result :continue)
                       (when (> i 0)
                         (recur (dec i)))
                       result)))))
      (filter identity))))

(defn find-entrances
  [definition]
  (into {}
        (for [direction directions]
          [direction (scan-for definition "i" direction)])))

(defn find-exits
  [definition]
  (into {}
        (for [direction directions]
          [direction (scan-for definition "o" direction)])))

(defn base-orientation
  [definition]
  {:entrances (find-entrances definition)
   :exits (find-exits definition)})

(defn all-transformations
  [base]
  [base])

(defn add-orientations
  [room]
  (->>
    room
    :definition
    base-orientation
    all-transformations
    (assoc room :orientations)))

(defn augment
  [room-list]
  (mapv add-orientations room-list))

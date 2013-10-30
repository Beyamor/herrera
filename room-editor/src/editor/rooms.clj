(ns editor.rooms)

(def room-width 16)
(def room-height 16)

(def directions #{:north :south :east :west})

(defn get-tile
  [definition i j]
  (get-in definition [i j]))

(defn set-tile
  [definition i j value]
  (assoc-in definition [i j] value))

(def empty-room
  {:definition
   (vec (for [i (range room-width)]
          (vec (for [i (range room-height)]
                 " "))))
   :slices
   {:rows #{}
    :columns #{}}})

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

(defn swap-directions
  [base from->to]
  (let [get (fn [what dir]
              (get-in base [what (from->to dir)]))]
    {:entrances (into {}
                     (for [direction directions]
                      [direction (get :entrances direction)]))
    :exits (into {}
                (for [direction directions]
                 [direction (get :exits direction)]))})) 

(defn rotate
  [base rotation]
  (case rotation
    0   base
    90  (swap-directions
          base
          {:north :west
           :east :north
           :south :east
           :west :south})
    180 (swap-directions
          base
          {:north :south
           :east :west
           :south :north
           :west :east})
    270 (swap-directions
          base
          {:north :east
           :east :south
           :south :west
           :west :north})))

(defn mirror
  [base mirroring]
  (case mirroring
    nil         base
    :horizontal (swap-directions
                  base
                  {:north :north
                   :east :west
                   :south :south
                   :west :east})
    :vertical   (swap-directions
                  base
                  {:north :south
                   :east :east
                   :south :north
                   :west :west})))

(defn transformation
  [base rotation mirroring]
  (-> base
    (rotate rotation)
    (mirror mirroring)
    (merge {:transformation
            {:rotation (when-not (zero? rotation) rotation)
             :mirror mirroring}})))

(defn all-transformations
  [base]
  (for [rotation [0 90 180 270]
        mirroring [nil :horizontal :vertical]]
    (transformation
      base rotation mirroring)))

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

(defn update-room!
  [{:keys [model state]} updater & args]
  (when-let [selected-room (:selected-room @state)]
    (swap! model update-in [:rooms selected-room]
           #(apply updater % args))))

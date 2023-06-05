---
date: 2019-04-06
title: The helloAudio Store
date: 2019-04-06
---

For this application a large portion of the state is what would be stored as a project file on local machines. In this application, that file can be stored in a database as JSON, which can be quickly parsed when it is retrieved from the server. During runtime, this state must be watched to update the DOM when necessary. As this project may become quite large and complex, it requires functionality for observing specific elements for changes.

To handle all of this functionality, I developed `ts-quickstore`; a state management library written in typescript which provides a centralized place for this state to be held and provides functionality for it to be observed. It is available on npm and I have published the [source on my github](https://github.com/cassegfault/ts-quickstore). In this post I'll go over how I designed it, why, and touch on how it's used.

<!--readmore-->

## Internal Design

At its core the store is two very similar trees. The first stores all of the state data in its current form, and exists as the point of truth for current state. All state data is held within this tree and the serialized form of this tree can be saved and loaded.

```typescript
    // Public read-only access to the accessor tree
    public readonly state: Proxied<StoreType>;
    // Accessor tree
    private state_accessor: Proxied<StoreType>;
    // Single point of truth, state tree
    private internal_state: any;
```

The second is a proxy through which the state is accessed. All nodes on the tree are a proxy with accessors that can limit access, provide additional functionality, or modify the manner in which the state is being modified. This structure enforces the necessary access rules. Additionally, these proxies can call events when a property of the state is modified.

> One of the reasons for a single point of truth and an accessor for that singular point of truth is to avoid nasty situations in which sloppy state management can result in one set of components writing to a state object reference while another reads from a different reference entirely, despite both being expected to be at the same path. These issues are very difficult to debug when they arise and having confidence in a single point of truth can save much time while debugging issues where the described issue may not be the issue, but could be suspected to be a possibility. A single point of truth with a single accessor eliminates that possibility.

```typescript
public setup_state(new_state: StoreType) {
    if (this.internal_state) {
        this.internal_state.load(new_state);
    } else {
        this.internal_state = new_state;
    }
    /*
        ... setup history, future ...
    */
    // builds (or rebuilds) the accessor tree
    this.update_state();
    /* ... */
}
```

When constructing the state, an initial state object is passed in to the constructor which will subsequently have it's `load` function called. The pattern expected is for every class to have its own load function that can take in an object and reset itself without needing to reconstruct the instance. This allows the store to completely serialize to JSON, then deserialize back with members of the state inheriting from classes defined in the project.

The state is modified through mutations which are defined when the store implementation is created. These mutations are synchronous but can be called from asynchronous actions, which may also call multiple mutations at once.

```typescript
/** Calls an mutation `key` with paramater `payload`, should only be called from actions */
public commit<K extends Extract<keyof ExtendMutations<MutationsType>, string>>(key: K, payload?: any) {
    this.is_mutating = true;

    var params = {
        state: this.state_accessor,
        payload
    };
    this.mutations[key](params);
    this.update_state();

    if (!this.history_checkpoint)
        this.commit_history_batch();

    this.is_mutating = false;
    return true;
}

/** Calls an action `key` with paramater `payload` */
public dispatch<K extends Extract<keyof ExtendActions<ActionsType>, string>>(key: K, payload?: any) {
    if (!this.actions[key]) {
        error(`Action dispatched that does not exist: ${key}`);
        return;
    }
    return this.actions[key]({
        commit: this.commit.bind(this),
        dispatch: this.dispatch.bind(this),
        payload
    });
}
```

Mutations must be called by `commit`, and mutations cannot invoke other mutations. Mutations are intended to be single changes to the state. This may mean that multiple nodes are changed, but in a singular fashion. This is to prevent very confusing situations where calling a single mutation results in unexpected changes to state or performance issues. Actions, called by `dispatch`, are meant for bundling these commits and as such may be asynchronous, call multiple mutations, and even call other actions.

```typescript
public dispatch<K extends Extract<keyof ExtendActions<ActionsType>, string>>>(key: K /*...*/)
```

In order to provide static checks to make sure the actions being used in the dispatch and commit calls exist for the current store the keys must be extracted from the actions sent in. `ActionsType` is the generic for the actions typing passed into the constructor and `ExtendActions` provides all additional actions provided by the store class. Finally, we ensure `key` is in this list by extracting keys as strings via `Extract<keyof ..., string>` and matching the key to that list using `extends`.

```typescript
function set_property({ state, payload: { value_object, path } }) {
  var current = state;
  path.forEach((part) => {
    current = current[part];
  });

  Object.keys(value_object).forEach((key) => {
    current[key] = value_object[key];
  });
}
```

There are times in which it can be difficult, unnecessary, or redundant to build actions or mutations to modify an object. There are many circumstances in which a small change needs to be made to a node which only affects that node. For these circumstances, each node contains a `set_property` mutation made accessible through the accessor tree. This provides a much simpler approach to modifying the state. However, some may choose to avoid this property to ensure state changes have categorized abstractions such as enforcing value limits. Both patterns are made available for flexibility.

Each time the state is modified, the modification is pushed into a list of previous mutations. This serves as a history of all of the changes to the state from the initial load to the current state. Using this history it is possible to revert a change to the state, which will in turn shift that change into a separate list which serves as a future. With these, we are able to call Undo and Redo on all changes to the state.

```typescript
// Save a checkpoint
public will_update(path?: string[] | string) {
    // build a deep copy of what is at path
    if (path && !isArray(path)) {
        path = (<string>path).split(".");
    }
    this.history_checkpoint = deepCopy(this.get_value_by_path(path as string[]));
}

// Commit the checkpoint
public did_update(path?: string[] | string) {
    if (path && !isArray(path)) {
        path = (<string>path).split(".");
    }
    this.events.fire(STATE_CHANGED, path || []);
    if (!this.history_checkpoint)
        return;
    // diff what is at path and what was at path and save that to history
    var currentPath = path as string[],
        diffObject = deep_diff(this.history_checkpoint, this.get_value_by_path(currentPath)),
        state_diff = {},
        build_tree = (obj, i = 0) => {/*...*/ };
    build_tree(diffObject);

    // put it into history
    this.currentHistoryBatch.push({
        stateData: state_diff,
        type: 'BatchedMutation'
    });
    this.commit_history_batch();
    this.history_checkpoint = null;
}
```

Given that some interactions require frequent changes to state that are not relevant to the work history of the application, it is important to be able to batch state changes to be stored in history as a single mutation. One example of this may be positioning an element through dragging. The state defines the display of the object and must be updated regularly while dragging, but none of those individual updates are meaningful; only the last position. To solve this issue, the store can create a checkpoint and not store any history until notified that the final mutation is complete.

> In the prototype code the state history is stored as a full copy of the state at each point in history. This is not necessary and could be avoided through diffing, storing only what has changed. This diffing function, when implemented, will speed up the store in many areas such as described above, any time the state is 'walked' (described below), and will reduce unnecessary event calls.

```typescript
/** Updates all objects in the state to be proxies and be accessible by path */
private update_state() {
    var currentPath = [],
        walk_state = (obj) => {
            Object.keys(obj).forEach((key) => {
                if ((isObj(obj[key]) || isArray(obj[key])) && obj.propertyIsEnumerable(key)) {
                    currentPath.push(key);
                    walk_state(obj[key]);
                    currentPath.pop();
                    if (!obj[key].__store_path__ && obj.propertyIsEnumerable(key)) {
                        // not a proxy
                        this.is_silently_modifying = true;
                        obj[key] = this.proxy_by_path([].concat(currentPath, [key]));
                        this.is_silently_modifying = false;
                    }
                }
            });
        }
    walk_state(this.state_accessor);
}
```

When commits result in new nodes on the state tree, those nodes need to be added to the accessor tree. Proxies as of ES2017 are not easily detectable, however our accessor tree extends each node with a special property to retrieve the path to that node. Using this we are able to walk the accessor tree looking for nodes which do not have this property (these are real state object references) and add them to the accessor tree.

```typescript
/** Fires `callback` when `path` has been changed
 * @param callback Fires when `path has been changed
 * @param path The path or paths to check. Paths are property names concatenated by '.'
 * @returns String ID of the event handler which can be used to destruct the event handler
 */
public add_observer(path: string[] | string, callback: (...args) => void) {
    var check_paths = (<string[]>(isArray(path) ? path : [path])).map((str) => str.split('.'));

    var handler_id = this.events.on(STATE_CHANGED, callback, (changed_path: string[]) => {
        if (changed_path.length < 1) {
            return true;
        }

        var found_match = check_paths.find((check_path) => {
            // Find the first item along the observed path that does not match the changed path
            // Note: if the observed path is shorter, it will fire on any changes to changed children
            var found_diff = check_path.find((prop, index) => {
                return check_path[index] !== '@each' && check_path[index] !== changed_path[index];
            });

            return found_diff === undefined;
        });

        return found_match !== undefined;
    });

    return handler_id;
}
```

One of the benefits of having an accessor tree used for all state modifications is being able to call a function as a result of a state change. Using a map of observed paths to callback functions, whenever the state change hook is fired those paths can be checked for changes and the appropriate callbacks fired. The state change hook provides a state path, and each observer provides an abstraction of a state path (or state paths) as well. The observed paths have abstractions to watch properties of each item in a list and can also fire when any child node is changed.

> The prototype implementation of these observers could see significant performance degredation as the store scales due to observers being added adds to the total work done when the state changes. This could be mitigated by switching to a search tree which would eliminate checking most branches and provide significant performance improvements as the store scales.
>
> Future versions of the store will also include a clipboard with similar functionality to the state history/future.

When the store is initialized it requires a type to be passed in (this is usually as simple as passing in `typeof initialState`), which is then passed to the accessor tree with the modifications in place to access the special proxy items. This means that anywhere you are accessing the state within the codebase you have typing information and code completion for the entire accessor tree and special proxy accessors.

The store's type system also allows for the store implementation's actions and mutations to be accessed by name when calling commit or dispatch and will throw static, in-editor errors when calling an action or mutation that does not exist. With this implementation there are no hidden, mistyped action artifacts in production code.

## API Design

The base API of the store is largely based on Vuex. The instantiation, actions, and mutations are built to be a very familiar API to the one in Vuex. However, There are several key differentiators in place to make the store more flexible and easier to develop with.

```typescript
const myStore = new Store<
  typeof initial_state,
  typeof actions,
  typeof mutations
>({
  initial_state,
  actions,
  mutations,
});
```

The store is initialized with initial state, actions, mutations, and type definitions for each. Each are passed in as separate objects, providing an easy way to have each piece in a separate file or even their own module.

Actions can be asynchronous, call multiple commits, or even dispatch other actions. Both actions and mutations pass a single object intended to be destructured within the parameters. Commit and dispatch each take a key and a payload, where the key is the name of the function.

```typescript
const actions = {
    async getTodoItems({ commit, payload: { listName }, dispatch }) {
        await todos = myApi.getTodos(listName);

        commit('setTodos', todos);

        todos.forEach((todo) => {
            dispatch('unnecessary_postprocess', todo);
        });
    }
    //...
}
```

Mutations are much more rigid than actions. They cannot call other mutations, must be synchronous, and are intended to be singularly focused. As the store scales and undergoes many mutations understanding the current state should be as simple as looking at what mutations were called. Due to mutations and actions being properties of an object, they must be named and as such none will be anonymous from within profiling tools, making state issues easy to track.

```typescript
const mutations = {
  setTodos({ payload: todos, state }) {
    state.todos = todos.map((todo) => new TodoItem(todo));
  },
  addTodo({ state }) {
    state.todos.push(new TodoItem());
  },
  //...
};
```

After constructing the store the state is accessible through a readonly proxy. This provides static checking against writing to the state directly. The typings passed in to the constructor allow the full state to be accessible in code completion along with the additional properties provided by the state.

Any state object has an accessible store path property as well as an action named `set_property` which is an ease-of-use action that can be called by any state item directly to modify its contents. This action will immediately mutate the object calling it, setting the state objects properties to the values of the corresponding properties on the object passed in.

```typescript
var myTodo = myStore.state.todo_items[x];
myTodo.set_property({
  title: "Finish blog post",
  done: false,
});
```

State history is managed via `undo`, `redo`, `history`, and `future`. By default, every commit results in an addition to `history`. Undo will roll back the most recent history object and shift it into `future`. Redo takes the first object in `future` and applies it to the state.

```typescript
myStore.todos.length; // 3
myStore.dispatch("addTodo");
myStore.todos.length; // 4
myStore.undo();
myStore.todos.length; // 3
myStore.redo();
myStore.todos.length; // 4
```

There are times when state needs to be modified frequently, but not saved to history except at key points. For this, the utilities `will_update` and `did_update` are provided. Both of these functions can take a string defining the path to some node on the state or a state object's `__store_path__`, which will use that object exactly. `will_update` saves a checkpoint and disables committing to state history, `did_update` uses the checkpoint to save only the modified state to history, ignoring all the steps in-between. At this point `undo` will reset the modified state to what it was at the point `will_update` was called.

```typescript
class DraggableBox {
    //...
    onMouseDown () {
        myStore.will_update(selectionBox.__store_path__);
    },

    onMouseMove (evt) {
        selectionBox.set_property({
            x: evt.pageX,
            y: evt.pageY
        });
    },

    onMouseUp () {
        myStore.did_update(selectionBox.__store_path__);
    }
    //...
}
```

The `add_observer` tool allows callbacks to be fired when a piece of state changes. It takes in a list of paths in the state stored in strings. These paths are written as they would be in javascript, property names concatenated by '.', but each node contains an additional property that can be used, `@each`. `@each` observes every node under the parent. This is particularly useful in cases of arrays, but is not limited to arrays.

```typescript
const myCallback = () => {
  /* ... */
};
myStore.addObserver(
  ["todos.@each.done", "account.preferences.notifications"],
  myCallback
);
```

Observer callbacks will only fire when one of the dependent keys is modified or one of the children of the dependent keys is modified. For example, when `account.preferences` is observed and `account.preferences.notifications` is changed, the observer will fire.

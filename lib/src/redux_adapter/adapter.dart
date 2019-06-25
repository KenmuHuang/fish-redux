import 'package:fish_redux/src/redux_component/basic.dart';
import 'package:fish_redux/src/redux_component/context.dart';
import 'package:flutter/widgets.dart' hide Action;

import '../../fish_redux.dart';
import '../redux/redux.dart';
import '../redux_component/logic.dart';
import '../redux_component/redux_component.dart';

/// abstract for custom extends
abstract class Adapter<T> extends Logic<T> implements AbstractAdapter<T> {
  final AdapterBuilder<T> _adapter;

  AdapterBuilder<T> get protectedAdapter => _adapter;

  Adapter({
    @required AdapterBuilder<T> adapter,
    Reducer<T> reducer,
    ReducerFilter<T> filter,
    Effect<T> effect,
    HigherEffect<T> higherEffect,
    Dependencies<T> dependencies,
    Object Function(T) key,
  })  : assert(adapter != null),
        assert(dependencies?.list == null,
            'Unexpected dependencies.list for Adapter.'),
        _adapter = adapter,
        super(
          reducer: reducer,
          filter: filter,
          effect: effect,
          higherEffect: higherEffect,
          dependencies: dependencies,
          key: key,
        );

  @override
  ListAdapter buildAdapter(ContextSys<T> ctx) =>
      ctx.enhancer
          ?.adapterEnhance(protectedAdapter, this, ctx.store)
          ?.call(ctx.state, ctx.dispatch, ctx) ??
      protectedAdapter?.call(ctx.state, ctx.dispatch, ctx);

  @override
  ContextSys<T> createContext(
    Store<Object> store,
    BuildContext buildContext,
    Get<T> getState, {
    @required Enhancer<Object> enhancer,
    @required DispatchBus bus,
  }) {
    assert(bus != null && enhancer != null);
    return AdapterContext<T>(
      logic: this,
      store: store,
      buildContext: buildContext,
      getState: getState,
      bus: bus,
      enhancer: enhancer,
    );
  }
}

class AdapterContext<T> extends LogicContext<T> {
  AdapterContext({
    @required Adapter<T> logic,
    @required Store<Object> store,
    @required BuildContext buildContext,
    @required Get<T> getState,
    @required DispatchBus bus,
    @required Enhancer<Object> enhancer,
  })  : assert(bus != null && enhancer != null),
        super(
          logic: logic,
          store: store,
          buildContext: buildContext,
          getState: getState,
          bus: bus,
          enhancer: enhancer,
        );

  @override
  ListAdapter buildAdapter() {
    final Adapter<T> curLogic = logic;
    return curLogic.buildAdapter(this);
  }
}

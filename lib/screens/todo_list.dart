import 'package:flutter/material.dart';
import 'package:todo_app/screens/add_page.dart';
import 'package:todo_app/service/todo_service.dart';
import 'package:todo_app/utils/snackbar_helper.dart';
import 'package:todo_app/widget/todo_card.dart';

class TodoListPage extends StatefulWidget {
  const TodoListPage({super.key});

  @override
  State<TodoListPage> createState() => _TodoListPageState();
}

class _TodoListPageState extends State<TodoListPage> {
  bool isLoading = true;
  List items = [];

  @override
  void initState() {
    super.initState();
    fetchTodo();
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Todo App'),
        centerTitle: true,
      ),
      body: Visibility(
        visible: isLoading,
        child: Center(child: CircularProgressIndicator()),
        replacement: RefreshIndicator(
          onRefresh: fetchTodo,
          child: Visibility(
            visible: items.isNotEmpty,
            replacement: Center(
              child: Text(
                'No Todo Item',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
            ),
            child: ListView.builder(
              itemCount: items.length,
              padding: EdgeInsets.all(10),
              itemBuilder: (context, index) {
                final item = items[index] as Map;
                return TodoCard(
                  index:  index,
                  item: item,
                  deleteById: deleteById,
                  navigateToEdit: navigateToEditPage,
                );
              },
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: navigateToAddPage,
        label: Text('Add Todo'),
      ),
    );
  }

  Future<void> navigateToEditPage(Map item) async {
    final route = MaterialPageRoute(
      builder: (context) => AddTodoPage(todo: item),
    );
    await Navigator.push(context, route);
    setState(() {
      isLoading = true;
    });
    fetchTodo();
  }

  Future<void> navigateToAddPage() async {
    final route = MaterialPageRoute(
      builder: (context) => AddTodoPage(),
    );
    await Navigator.push(context, route);
    // Auto refresh after add
    setState(() {
      isLoading = true;
    });
    fetchTodo();
  }

  Future<void> deleteById(String id) async {
    // Delete all item
    final isSuccess = await TodoService.deleteById(id);
    if (isSuccess) {
      // Remove item from the list
      final filtered = items.where((element) => element['_id'] != id).toList();
      setState(() {
        items = filtered;
      });
    } else {
      // Show error
      showErrorMessage(context, message: 'Deletion Failed');
    }
  }

  Future<void> fetchTodo() async {
    final response = await TodoService.fetchTodo();
    if (response != null) {
      setState(() {
        items = response;
      });
    } else {
      showErrorMessage(context, message: 'Something went wrong');
    }
    setState(() {
      isLoading = false;
    });
  }
}

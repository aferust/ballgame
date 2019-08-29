module vvector;

import core.stdc.stdlib;

struct Dvector(T) {
    vector v;
    size_t length = 0;
    
    alias opDollar = length;
    
    void _init_() @nogc nothrow{
        length = 0;
        vector_init(&v);
    }
    
    void pBack(T elem) @nogc nothrow{
        vector_add(&v, elem);
        length ++;
    }
    
    T opIndex(int i) @nogc nothrow {
        return cast(T)vector_get(&v, i);
    }
    
    void opIndexAssign(T elem, int i) @nogc nothrow {
        vector_set(&v, i, elem);
    }
    
    void remove(int i) @nogc nothrow{
        vector_delete(&v, i);
        length --;
    }
    
    void free(){
        vector_free(&v);
    }
}

// based on https://eddmann.com/posts/implementing-a-dynamic-vector-array-in-c/
enum VECTOR_INIT_CAPACITY = 4;

private @nogc nothrow:

struct vector {
    void **items;
    int capacity;
    int total;
}

void vector_init(vector *v)
{
    v.capacity = VECTOR_INIT_CAPACITY;
    v.total = 0;
    v.items = cast(void**)malloc((void*).sizeof * v.capacity);
}

int vector_total(vector *v)
{
    return v.total;
}

static void vector_resize(vector *v, int capacity)
{
    version(Debug){
        import core.stdc.stdio;
        printf("vector_resize: %d to %d\n", v.capacity, capacity);
    }

    void **items = cast(void**)realloc(v.items, (void *).sizeof * capacity);
    if (items) {
        v.items = items;
        v.capacity = capacity;
    }
}

void vector_add(vector *v, void *item)
{
    if (v.capacity == v.total)
        vector_resize(v, v.capacity * 2);
    v.items[v.total++] = item;
}

void vector_set(vector *v, int index, void *item)
{
    if (index >= 0 && index < v.total)
        v.items[index] = item;
}

void *vector_get(vector *v, int index)
{
    if (index >= 0 && index < v.total)
        return v.items[index];
    return null;
}

void vector_delete(vector *v, int index)
{
    if (index < 0 || index >= v.total)
        return;

    v.items[index] = null;

    for (int i = index; i < v.total - 1; i++) {
        v.items[i] = v.items[i + 1];
        v.items[i + 1] = null;
    }

    v.total--;

    if (v.total > 0 && v.total == v.capacity / 4)
        vector_resize(v, v.capacity / 2);
}

void vector_free(vector *v)
{
    free(v.items);
}

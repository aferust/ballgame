module memory;

import std.stdio;
import std.traits;
import std.container;
// kaynak: https://www.auburnsounds.com/blog/2016-11-10_Running-D-without-its-runtime.html

/// Assumes a function to be nothrow and @nogc
auto assumeNothrowNoGC(T) (T t) if (isFunctionPointer!T || isDelegate!T)
{
    enum attrs = functionAttributes!T
               | FunctionAttribute.nogc
               | FunctionAttribute.nothrow_;
    return cast(SetFunctionAttributes!(T, functionLinkage!T, attrs)) t;
}
//////////////////////////////////////////////////////////////////////////////////////
// For classes
void destroyNoGC(T)(T x) nothrow @nogc
    if (is(T == class) || is(T == interface))
{
    assumeNothrowNoGC(
        (T x)
        {
            return destroy(x);
        })(x);
}

// For structs
void destroyNoGC(T)(ref T obj) nothrow @nogc
    if (is(T == struct))
{
    assumeNothrowNoGC(
        (ref T x)
        {
            return destroy(x);
        })(obj);
}
///////////////////////////////////////////////////////////////////////////////////////

/// Allocates and construct a class or struct object.
/// Returns: Newly allocated object.
auto mallocEmplace(T, Args...)(Args args)
{
    import std.conv;
    import core.stdc.stdlib;
    
    static if (is(T == class))
        immutable size_t allocSize = __traits(classInstanceSize, T);
    else
        immutable size_t allocSize = T.sizeof;

    void* rawMemory = malloc(allocSize);
    if (!rawMemory)
        onOutOfMemoryErrorNoGC();

    static if (is(T == class))
    {
        T obj = emplace!T(rawMemory[0 .. allocSize], args);
    }
    else
    {
        T* obj = cast(T*)rawMemory;
        emplace!T(obj, args);
    }

    return obj;
}

void onOutOfMemoryErrorNoGC(){
    printf("Memory error \n");
}


/// Destroys and frees an object created with `mallocEmplace`.
void destroyFree(T)(T p) if (is(T == class) || is(T == interface))
{
    import core.stdc.stdlib;
    if (p !is null)
    {
        static if (is(T == class))
        {
            destroyNoGC(p);
            free(cast(void*)p);
        }
        else
        {
            // A bit different with interfaces,
            // because they don't point to the object itself
            void* here = cast(void*)(cast(Object)p);
            destroyNoGC(p);
            free(cast(void*)here);
        }
   }
}

/// Destroys and frees a non-class object created with `mallocEmplace`.
void destroyFree(T)(T* p) if (!is(T == class) && !is(T == interface))
{
    import core.stdc.stdlib;
    if (p !is null)
    {
        destroyNoGC(p);
        free(cast(void*)p);
    }
}


/+
instead of throw new Exception("Message")
throw mallocEmplace!Exception("Message");

try
{
    doSomethingThatMightThrow(userInputData);
    return true;
}
catch(Exception e)
{
    e.destroyFree(); // release e manually
    return false;
}

+/

class Hayvan {
    uint age;
    uint length;
    
    this(){
        age = 0;
        length = 1;
        printf("Hello, I'm allocated!\n");
    }
    
    ~this(){
        printf("byeeee!\n");
    }
    
    void makeSound(){
        printf("Hrrrrrrrrrrrrr\n");
    }
}

void deneme(Hayvan ob){
    ob.age = 4;
}
/+
void main()
{
    import core.stdc.stdlib;
    /*
    foreach(i; 0..10000){
        Hayvan ob = mallocEmplace!Hayvan;
        ob.makeSound();
        destroyFree(ob);
    }
    */
    
    auto arr = Array!Hayvan();
    Hayvan ob = mallocEmplace!Hayvan;
    ob.age = 3;
    deneme(ob);
    arr.length = 1;
    arr[0] = ob;
    printf("%d\n", arr[0].age);
    ob.destroyFree;
    free(&arr);
    
    getchar();
}
+/

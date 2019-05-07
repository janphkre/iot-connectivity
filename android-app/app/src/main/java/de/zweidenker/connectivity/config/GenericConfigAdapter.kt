package de.zweidenker.connectivity.config

import android.content.Context
import android.os.Handler
import android.support.annotation.LayoutRes
import android.support.v7.widget.RecyclerView
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup

class GenericConfigAdapter<T>(
    context: Context,
    @LayoutRes private val itemLayout: Int,
    private val onClick: (T) -> Unit,
    private val bind: (T, View) -> Unit
) : RecyclerView.Adapter<GenericConfigAdapter<T>.ViewHolder>() {

    private var items: List<T> = emptyList()
    private var foregroundHandler = Handler(context.mainLooper)

    fun setItems(newItems: List<T>) {
        synchronized(this) {
            items = newItems
            foregroundHandler.post {
                notifyDataSetChanged()
            }
        }
    }

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): ViewHolder {
        return ViewHolder(parent)
    }

    override fun getItemCount(): Int = items.size

    override fun onBindViewHolder(viewHolder: ViewHolder, position: Int) {
        viewHolder.setContent(items[position])
    }

    override fun onViewRecycled(holder: ViewHolder) {
        holder.clear()
    }

    inner class ViewHolder(parent: ViewGroup) : RecyclerView.ViewHolder(LayoutInflater.from(parent.context).inflate(itemLayout, parent, false)) {
        private var item: T? = null

        init {
            itemView.setOnClickListener {
                item?.let(onClick)
            }
        }

        fun setContent(item: T) {
            this.item = item
            bind.invoke(item, itemView)
        }

        fun clear() {
            item = null
        }
    }
}